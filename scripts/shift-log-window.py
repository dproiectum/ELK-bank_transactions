#!/usr/bin/env python3
"""Shift generated log timestamps across a chosen historical window.

This script intentionally does not modify generator/generate.py. It rewrites
timestamps in already generated log files when a wider Kibana time range is
useful for dashboard work.

By default, it avoids the professor's batch start date (2026-07-26) and spreads
existing log lines from 2026-07-27 up to yesterday. Today's timestamps are kept
free for the continuous generator.
"""
import argparse
import csv
import json
import random
import re
from datetime import date, datetime, time, timedelta, timezone
from pathlib import Path


TXN_RE = re.compile(r"ts=(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)")
ISO_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
DEFAULT_START = date(2026, 7, 27)


def parse_iso(value):
    return datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)


def fmt_iso(value):
    return value.strftime("%Y-%m-%dT%H:%M:%SZ")


def parse_start(value):
    if "T" not in value:
        value = value + "T00:00:00Z"
    if value.endswith("Z"):
        return parse_iso(value)
    return datetime.fromisoformat(value).astimezone(timezone.utc)


def parse_day(value):
    return datetime.strptime(value, "%Y-%m-%d").date()


def utc_midnight(day):
    return datetime.combine(day, time.min, tzinfo=timezone.utc)


def collect_records(log_dir, files):
    records = []
    lines_by_path = {}

    for name in files:
        path = log_dir / name
        if not path.exists():
            continue

        lines = path.read_text().splitlines()
        lines_by_path[path] = lines

        for line_no, line in enumerate(lines):
            old_ts = extract_timestamp(name, line)
            if old_ts is not None:
                records.append((old_ts, path, line_no))

    records.sort(key=lambda item: (item[0], str(item[1]), item[2]))
    return records, lines_by_path


def extract_timestamp(name, line):
    if name == "transactions.log":
        match = TXN_RE.search(line)
        return parse_iso(match.group(1)) if match else None

    if name == "auth.log":
        try:
            doc = json.loads(line)
        except json.JSONDecodeError:
            return None
        ts = doc.get("ts")
        return parse_iso(ts) if isinstance(ts, str) and ISO_RE.match(ts) else None

    if name == "atm.csv":
        if line.startswith("ts,"):
            return None
        row = next(csv.reader([line]))
        return parse_iso(row[0]) if row and ISO_RE.match(row[0]) else None

    return None


def replace_timestamp(name, line, new_ts):
    if name == "transactions.log":
        return TXN_RE.sub(f"ts={new_ts}", line, count=1)

    if name == "auth.log":
        doc = json.loads(line)
        doc["ts"] = new_ts
        return json.dumps(doc)

    if name == "atm.csv":
        row = next(csv.reader([line]))
        row[0] = new_ts
        return ",".join(row)

    return line


def build_day_counts(total, days, daily_min, daily_max, rng):
    raw_counts = [rng.randint(daily_min, daily_max) for _ in days]
    raw_total = sum(raw_counts)

    if raw_total == total:
        return raw_counts, None

    scaled = []
    carried = 0.0
    for raw in raw_counts:
        exact = (raw / raw_total) * total + carried
        count = int(exact)
        carried = exact - count
        scaled.append(count)

    diff = total - sum(scaled)
    for i in range(abs(diff)):
        idx = i % len(scaled)
        scaled[idx] += 1 if diff > 0 else -1

    min_possible = daily_min * len(days)
    max_possible = daily_max * len(days)
    if total < min_possible:
        note = (
            f"requested {daily_min}-{daily_max} logs/day, but only {total} "
            f"timestamps exist for {len(days)} days; counts were scaled down"
        )
    elif total > max_possible:
        note = (
            f"requested {daily_min}-{daily_max} logs/day, but {total} "
            f"timestamps exist for {len(days)} days; counts were scaled up"
        )
    else:
        note = "daily random counts were normalized to keep the same total line count"

    return scaled, note


def build_random_timestamps(days, counts, rng):
    timestamps = []
    for day, count in zip(days, counts):
        start = utc_midnight(day)
        seconds_in_day = 24 * 60 * 60 - 1
        for _ in range(count):
            timestamps.append(start + timedelta(seconds=rng.randint(0, seconds_in_day)))

    timestamps.sort()
    return timestamps


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--logs", default="logs", help="logs directory")
    parser.add_argument("--start", default=str(DEFAULT_START),
                        help="first historical day, default: 2026-07-27")
    parser.add_argument("--end", help="last historical day, default: yesterday")
    parser.add_argument("--days", type=int,
                        help="number of days to cover from --start; overrides --end")
    parser.add_argument("--daily-min", type=int, default=3000,
                        help="target minimum timestamps per day, default: 3000")
    parser.add_argument("--daily-max", type=int, default=10000,
                        help="target maximum timestamps per day, default: 10000")
    parser.add_argument("--seed", type=int, default=20260727,
                        help="random seed for reproducible timestamp distribution")
    args = parser.parse_args()

    if args.daily_min <= 0 or args.daily_max <= 0 or args.daily_min > args.daily_max:
        parser.error("--daily-min and --daily-max must be positive, with min <= max")

    log_dir = Path(args.logs)
    files = ["transactions.log", "auth.log", "atm.csv"]
    records, lines_by_path = collect_records(log_dir, files)

    if not records:
        print(f"no timestamps found in {log_dir}")
        return

    start_day = parse_day(args.start)
    if args.days:
        if args.days <= 0:
            parser.error("--days must be greater than 0")
        end_day = start_day + timedelta(days=args.days - 1)
    elif args.end:
        end_day = parse_day(args.end)
    else:
        end_day = datetime.now(timezone.utc).date() - timedelta(days=1)

    if end_day < start_day:
        parser.error("the end day must be on or after the start day")

    days = [start_day + timedelta(days=i) for i in range((end_day - start_day).days + 1)]
    total = len(records)
    rng = random.Random(args.seed)
    day_counts, note = build_day_counts(total, days, args.daily_min, args.daily_max, rng)
    timestamps = build_random_timestamps(days, day_counts, rng)

    for (_old_ts, path, line_no), timestamp in zip(records, timestamps):
        new_ts = fmt_iso(timestamp)
        name = path.name
        lines_by_path[path][line_no] = replace_timestamp(name, lines_by_path[path][line_no], new_ts)

    for path, lines in lines_by_path.items():
        path.write_text("\n".join(lines) + "\n")

    print(f"shifted {total} timestamps in {log_dir}/")
    print(f"window: {start_day.isoformat()} -> {end_day.isoformat()} (today excluded)")
    print("daily counts:")
    for day, count in zip(days, day_counts):
        print(f"  {day.isoformat()}: {count}")
    if note:
        print(f"note: {note}")


if __name__ == "__main__":
    main()

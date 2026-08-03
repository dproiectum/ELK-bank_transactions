# ELK-bank_transactions

Project progress is tracked in [PROJECT_STATUS.md](PROJECT_STATUS.md).
Dashboard planning is documented in [kibana/DASHBOARD_PLAN.md](kibana/DASHBOARD_PLAN.md).
Raw log fields are documented in [logs/LOG_FIELDS.md](logs/LOG_FIELDS.md).

## Architecture

```text
generator/generate.py
        |
        v
logs/
  - transactions.log
  - auth.log
  - atm.csv
        |
        v
Logstash
  - parse key=value-like transactions with a strict grok pattern
  - parse JSON auth events
  - parse CSV ATM events
  - enrich auth IPs with geoip
  - route malformed lines to dead-letter
        |
        v
Elasticsearch
  - bank-transactions-YYYY.MM.dd
  - bank-auth-YYYY.MM.dd
  - bank-atm-YYYY.MM.dd
  - bank-deadletter-YYYY.MM.dd
  - alerts
        |
        v
Kibana dashboard + alert rule
```

## Run

From this directory:

```bash
docker compose up -d
```

This only creates and starts the ELK containers. It does not generate new log lines. Log generation is always a user decision.

Kibana: <http://localhost:5601>  
Elasticsearch: <http://localhost:9200>

When you want to reset the project to zero, run:

```bash
./scripts/seed.sh
```

This deletes generated log files and project Elasticsearch indices. It does not generate new logs.

When you decide to add a fixed batch of logs, run the provided generator manually:

```bash
python3 generator/generate.py --batch 5000
```

The generator is kept unchanged from the provided `bank-transactions` kit. Batch logs start on `2026-07-26`, so in Kibana use an absolute time range that includes that date.

## Generator

The provided generator supports two modes:

```bash
python3 generator/generate.py --batch 5000
```

This appends a batch of 5000 transaction events, plus related auth and ATM lines, then exits.

```bash
python3 generator/generate.py
```

This appends logs continuously with current timestamps. Run it in a dedicated terminal window because it does not stop by itself. Stop it with `Ctrl+C`.

You can also use the small streaming wrapper:

```bash
./scripts/stream.sh
```

It prints where logs are written, runs the original continuous generator, and reports progress every 100 new lines.

The project also provides a reset wrapper:

```bash
./scripts/seed.sh
```

`seed.sh` cleans existing generated logs and Elasticsearch project indices. It does not call the generator. Batch generation remains a manual user action.

Important: `generator/generate.py` is part of the provided subject and should not be modified.

## Optional Time Window Shift

The provided generator is intentionally kept unchanged. By default, its batch data is concentrated around `2026-07-26`.

If you want a dashboard spread across several historical days without modifying the subject generator, first generate logs, then shift timestamps in the generated files:

```bash
python3 generator/generate.py --batch 5000
python3 scripts/shift-log-window.py
```

This rewrites timestamps in:

```text
logs/transactions.log
logs/auth.log
logs/atm.csv
```

It preserves the generated lines and formats, but spreads valid timestamps from `2026-07-27` to yesterday. Today's date is intentionally excluded, so continuous generation can use current timestamps without mixing with the historical batch.

The default distribution tries to vary each day between 3000 and 10000 timestamps. If the existing files contain too few or too many timestamps to respect that range exactly, the script keeps the same total number of lines and prints a note explaining that daily counts were scaled.

Examples:

```bash
# Default: 2026-07-27 through yesterday
python3 scripts/shift-log-window.py

# Explicit period
python3 scripts/shift-log-window.py --start 2026-07-27 --end 2026-08-02

# Explicit number of days from the start date
python3 scripts/shift-log-window.py --start 2026-07-27 --days 7
```

After shifting timestamps, reset Elasticsearch indices and restart Logstash so the rewritten files are indexed again:

```bash
./scripts/clean-indices.sh
docker compose restart logstash
```

## Cleaning

Cleaning is explicit. Choose what you want to reset.

Delete generated log files only:

```bash
./scripts/clean-logs.sh
```

Delete project Elasticsearch indices only:

```bash
./scripts/clean-indices.sh
```

For a fresh validation run:

```bash
./scripts/seed.sh
python3 generator/generate.py --batch 5000
```

Do not use continuous mode for the acceptance count, because generated line counts keep increasing.

## Acceptance Count

After running the batch generator, wait 10-20 seconds and compare generated input lines with indexed documents:

```bash
wc -l logs/transactions.log logs/auth.log logs/atm.csv
curl -s 'http://localhost:9200/_cat/indices/bank-*?h=index,docs.count' | sort
```

The expected rule is:

```text
business indices + dead-letter = generated lines
```

The CSV header is routed to `bank-deadletter-*` with reason `csv_header` so the line count remains auditable.

For a clean acceptance count, run `./scripts/seed.sh`, then run `python3 generator/generate.py --batch 5000`.

## Logstash Debug Output

The pipeline prints events with the `rubydebug` codec, like in Lab 2. To inspect parsed events:

```bash
docker compose logs -f logstash
```

You should run this command from the project root, where `docker-compose.yml` is located.

## Included Generator

The original `bank-transactions` generator is included in this repository:

```text
generator/generate.py
logs/.gitkeep
```

Generated log files are ignored by Git. Use `scripts/clean-logs.sh` when you want to delete them.

## Dashboard Questions

Build one Kibana dashboard answering these 8 questions:

1. Transaction volume and value over time, by currency.
2. Approval rate over time.
3. Top 10 merchants by transaction value.
4. Top decline reasons.
5. Card-present vs card-not-present split, per country.
6. ATM cities dispensing the most cash, plus ATM error rate.
7. Fraud attack: when, from which country, and signature.
8. Share of unparseable lines today.

## Alert

Create a Kibana rule:

```text
Index: bank-transactions-*
Condition: count > 20
Window: 5 minutes
Filter:
  status: declined
  card_present: false
Action: write to alerts index
```

The generated anomaly should appear around the middle/end part of the batch. It is a burst of declined card-not-present transactions from `US`, usually with `reason=suspected_fraud`, and matching auth failures from the `181.214.200.0/21`-like IP range.

## Choices And Trade-Offs

- A strict `grok` pattern is used for `transactions.log`: it keeps the key=value structure predictable and avoids treating `card_present=false` as a missing field.
- `json` is used for `auth.log` because the source is already JSON lines.
- `csv` is used for `atm.csv` because the source is a regular comma-separated export.
- Separate indices make mappings simple and keep each source easy to reason about.
- `auth.log` gets GeoIP enrichment because IP geography helps explain the fraud signature.
- Malformed lines are not dropped. They are indexed into `bank-deadletter-*` with the original line and a reason.

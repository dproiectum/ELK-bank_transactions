# ELK-bank_transactions

Project progress is tracked in [PROJECT_STATUS.md](PROJECT_STATUS.md).
Dashboard planning is documented in [kibana/DASHBOARD_PLAN.md](kibana/DASHBOARD_PLAN.md).

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
./scripts/seed.sh 5000
```

Batch logs are spread across the last 7 days, ending when the seed command is launched. The distribution uses a realistic hourly curve: quiet nights, stronger daytime/evening traffic, and moderate day-to-day variation. In Kibana, use a relative time range such as `Last 8 days`.

Kibana: <http://localhost:5601>  
Elasticsearch: <http://localhost:9200>

## Continuous Generator

For the graded reproducible demo, use the seed command:

```bash
./scripts/seed.sh 5000
```

If you want to simulate real-time logs manually, run the original generator without `--batch`:

```bash
python3 generator/generate.py
```

This writes new log lines continuously with current timestamps. Stop it with `Ctrl+C`.

Do not use continuous mode for the acceptance count, because generated line counts keep increasing.

## Acceptance Count

After running the seed command, wait 10-20 seconds and compare generated input lines with indexed documents:

```bash
wc -l logs/transactions.log logs/auth.log logs/atm.csv
curl -s 'http://localhost:9200/_cat/indices/bank-*?h=index,docs.count' | sort
```

The expected rule is:

```text
business indices + dead-letter = generated lines
```

The CSV header is routed to `bank-deadletter-*` with reason `csv_header` so the line count remains auditable.

## Included Generator

The original `bank-transactions` generator is included in this repository:

```text
generator/generate.py
logs/.gitkeep
```

Generated log files are ignored by Git. They are recreated by `./scripts/seed.sh`.

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

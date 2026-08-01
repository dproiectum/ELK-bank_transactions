# Phase 1 - Logstash Ingestion

## Status

In progress.

## Goal

Parse all three bank transaction sources and route each generated line either to a business index or to a dead-letter index.

## Sources

| Source | File | Format | Target index |
| --- | --- | --- | --- |
| Transactions | `logs/transactions.log` | key=value-like line | `bank-transactions-*` |
| Authentication | `logs/auth.log` | JSON lines | `bank-auth-*` |
| ATM export | `logs/atm.csv` | CSV | `bank-atm-*` |

Malformed lines must go to:

```text
bank-deadletter-*
```

## Done

- Logstash file inputs are configured for all three sources.
- Transaction events are parsed with a strict `grok` pattern.
- Auth events are parsed with the `json` filter.
- ATM events are parsed with the `csv` filter.
- Auth events include GeoIP enrichment on `client_ip`.
- Malformed lines are routed to `bank-deadletter-*`.
- Original lines are preserved in `raw_line`.

## Problem Found

Before the latest correction, the dead-letter index was too large:

```text
bank-transactions-2026.07.26    2919 docs
bank-auth-2026.07.26            2964 docs
bank-atm-2026.07.26              754 docs
bank-deadletter-2026.08.01      2145 docs
```

Root cause:

```text
Valid transactions with card_present=false were incorrectly routed to dead-letter.
```

Fix applied:

```text
transactions.log parsing now uses a strict grok pattern instead of a fragile post-kv field presence check.
```

## Next Test

Run:

```bash
docker compose restart logstash
./scripts/seed.sh 5000
curl -s 'http://localhost:9200/_cat/indices/bank-*?h=index,docs.count' | sort
```

Expected:

```text
bank-deadletter-* should be close to the intentional malformed-line rate.
business indices + dead-letter should equal generated input lines.
```

## Related Files

- [`logstash/pipeline/pipeline.conf`](../logstash/pipeline/pipeline.conf)
- [`scripts/seed.sh`](../scripts/seed.sh)

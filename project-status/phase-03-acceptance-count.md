# Phase 3 - Acceptance Count

## Status

Done.

## Goal

Prove the final project rule:

```text
business indices + dead-letter = generated input lines
```

## Why This Matters

The project statement says there must be no silent data loss. Every generated line must either become a structured business document or a dead-letter document.

## Commands

For a clean validation run:

```bash
./scripts/clean-logs.sh
./scripts/clean-indices.sh
./scripts/seed.sh 5000
```

Generated input lines:

```bash
wc -l logs/transactions.log logs/auth.log logs/atm.csv
```

Indexed documents:

```bash
curl -s 'http://localhost:9200/_cat/indices/bank-*?h=index,docs.count' | sort
```

Dead-letter reasons:

```bash
curl -s 'http://localhost:9200/bank-deadletter-*/_search?pretty' \
  -H 'Content-Type: application/json' \
  -d '{"size":0,"aggs":{"reasons":{"terms":{"field":"deadletter_reason","size":20}}}}'
```

## Validated Count

Batch logs are spread across the last 7 days, ending when the seed command is launched. The generator uses a realistic hourly/day curve inspired by Lab 3.

The latest generated input files contain:

```text
transactions.log    5000 lines
auth.log            3003 lines
atm.csv              744 lines
total               8747 lines
```

Validated Elasticsearch counts are:

```text
bank-transactions-*  4895
bank-auth-*          2937
bank-atm-*            743
bank-deadletter-*     172
```

Total indexed documents:

```text
4895 + 2937 + 743 + 172 = 8747
```

Acceptance rule:

```text
business indices + dead-letter = generated input lines
8747 = 8747
```

## Remaining Work

- None for the count itself.
- Optional: document dead-letter reasons with an aggregation screenshot or command output.

## Validated Counts

Validated after the 7-day distribution update on 2026-08-01.

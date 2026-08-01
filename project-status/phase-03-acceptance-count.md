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

Batch logs are spread across the last 7 days, ending when the seed command is launched.

The latest generated input files contain:

```text
transactions.log    5000 lines
auth.log            3017 lines
atm.csv              755 lines
total               8772 lines
```

Validated Elasticsearch counts are:

```text
bank-atm-2026.07.26            754
bank-auth-2026.07.26          2960
bank-deadletter-2026.08.01     170
bank-transactions-2026.07.26  4888
```

Total indexed documents:

```text
754 + 2960 + 170 + 4888 = 8772
```

Acceptance rule:

```text
business indices + dead-letter = generated input lines
8772 = 8772
```

## Remaining Work

- None for the count itself.
- Optional: document dead-letter reasons with an aggregation screenshot or command output.

## Validated Counts

Validated from Kibana Dev Tools screenshot on 2026-08-01.

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
./scripts/seed.sh
python3 generator/generate.py --batch 5000
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

`generator/generate.py` is kept unchanged from the provided `bank-transactions` kit. Batch logs start on `2026-07-26`.

The latest generated input files contain:

```text
transactions.log    5000 lines
auth.log            3017 lines
atm.csv              755 lines
total               8772 lines
```

Validated Elasticsearch counts are:

```text
bank-transactions-*  4888
bank-auth-*          2960
bank-atm-*            754
bank-deadletter-*     170
```

Total indexed documents:

```text
4888 + 2960 + 754 + 170 = 8772
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

Validated with the provided generator timestamps on 2026-08-01.

# Phase 3 - Acceptance Count

## Status

In progress.

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

## Remaining Work

- Run the count check after the latest pipeline correction.
- Record the validated counts here.

## Validated Counts

Not validated yet after the latest pipeline correction.

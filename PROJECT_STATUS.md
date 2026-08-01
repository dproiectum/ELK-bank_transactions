# Project Status - ELK-bank_transactions

This file tracks the current state of the project so anyone following the GitHub repository can quickly understand what is done, what is in progress, and what remains.

Update this file before each meaningful commit.

## Current Phase

Phase 1 - Logstash ingestion is in progress.

The Docker stack starts and Elasticsearch/Kibana/Logstash containers are running. Elasticsearch indices are created, but ingestion still needs a clean verification pass after the latest Logstash parsing correction.

## Progress

| Phase | Status | Notes |
| --- | --- | --- |
| 0. Project structure | Done | Repository structure created with Docker, Logstash, Elasticsearch mappings, Kibana folder, generator, logs, and scripts. |
| 1. Logstash ingestion | In progress | Three sources are wired: transactions, auth, and ATM. A parsing issue with `card_present=false` was corrected. Needs retest. |
| 2. Elasticsearch mappings | Base done | Explicit index templates exist for business indices, dead-letter, and alerts. Needs validation after fresh indexing. |
| 3. Acceptance count | In progress | Need to prove: business docs + dead-letter docs = generated lines. |
| 4. Kibana data views | Not started | Need data views for `bank-transactions-*`, `bank-auth-*`, `bank-atm-*`, `bank-deadletter-*`, and `alerts*`. |
| 5. Kibana dashboard | Not started | Must answer the 8 business questions from the bank-transactions kit. |
| 6. Kibana alert | Not started | Alert: more than 20 declined card-not-present transactions within 5 minutes; action writes to `alerts`. |
| 7. Export saved objects | Not started | Export dashboard/rule to `kibana/dashboard.ndjson`. |
| 8. Final README and demo rehearsal | Partial | README exists, but needs final screenshots, validation counts, and defense notes. |

## Last Known Elasticsearch State

Before the latest pipeline correction, the project had too many dead-letter documents:

```text
bank-transactions-2026.07.26    2919 docs
bank-auth-2026.07.26            2964 docs
bank-atm-2026.07.26              754 docs
bank-deadletter-2026.08.01      2145 docs
```

Problem found:

```text
Valid transactions with card_present=false were incorrectly routed to dead-letter.
```

Fix applied:

```text
transactions.log parsing now uses a strict grok pattern instead of a fragile post-kv field presence check.
```

## Next Actions

Run from the project root:

```bash
docker compose restart logstash
./scripts/seed.sh 5000
curl -s 'http://localhost:9200/_cat/indices/bank-*?h=index,docs.count' | sort
```

Expected result:

```text
bank-deadletter-* should be close to the intentional malformed-line rate, not thousands of documents.
business indices + dead-letter should equal generated input lines.
```

## Commit Checklist

Before each commit:

```text
1. Update this PROJECT_STATUS.md file.
2. Mention the current phase.
3. Mention what changed.
4. Mention what still needs to be tested or completed.
5. Keep generated logs out of Git.
```

## Useful Commands

Start the stack:

```bash
docker compose up -d
```

Generate a deterministic batch:

```bash
./scripts/seed.sh 5000
```

Check index counts:

```bash
curl -s 'http://localhost:9200/_cat/indices/bank-*?h=index,docs.count' | sort
```

Check dead-letter reasons:

```bash
curl -s 'http://localhost:9200/bank-deadletter-*/_search?pretty' \
  -H 'Content-Type: application/json' \
  -d '{"size":0,"aggs":{"reasons":{"terms":{"field":"deadletter_reason","size":20}}}}'
```

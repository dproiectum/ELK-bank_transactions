# Project Status - ELK-bank_transactions

This file is the general project tracker. Each phase has its own detailed status file in [`project-status/`](project-status/).

Update this file and the relevant phase file before each meaningful commit.

## Current Phase

**Phase 1 - Logstash ingestion** is in progress.

The Docker stack starts and Elasticsearch/Kibana/Logstash containers are running. Elasticsearch indices are created, but ingestion still needs a clean verification pass after the latest Logstash parsing correction.

## Progress Overview

| Phase | Status | Details | Short Notes |
| --- | --- | --- | --- |
| 0. Project structure | Done | [phase-00-project-structure.md](project-status/phase-00-project-structure.md) | Repository structure exists and the generator/logs folders are at project root. |
| 1. Logstash ingestion | In progress | [phase-01-logstash-ingestion.md](project-status/phase-01-logstash-ingestion.md) | Three sources are wired. Transaction parsing was corrected and needs retest. |
| 2. Elasticsearch mappings | Base done | [phase-02-elasticsearch-mappings.md](project-status/phase-02-elasticsearch-mappings.md) | Explicit templates exist for business indices, dead-letter, and alerts. |
| 3. Acceptance count | In progress | [phase-03-acceptance-count.md](project-status/phase-03-acceptance-count.md) | Need to prove business docs + dead-letter docs = generated lines. |
| 4. Kibana data views | Not started | [phase-04-kibana-data-views.md](project-status/phase-04-kibana-data-views.md) | Data views need to be created in Kibana. |
| 5. Kibana dashboard | Not started | [phase-05-kibana-dashboard.md](project-status/phase-05-kibana-dashboard.md) | Dashboard must answer the 8 business questions. |
| 6. Kibana alert | Not started | [phase-06-kibana-alert.md](project-status/phase-06-kibana-alert.md) | Fraud alert must write to `alerts`. |
| 7. Export saved objects | Not started | [phase-07-export-saved-objects.md](project-status/phase-07-export-saved-objects.md) | Export dashboard/rule to `kibana/dashboard.ndjson`. |
| 8. Final README and demo rehearsal | Partial | [phase-08-final-readme-demo.md](project-status/phase-08-final-readme-demo.md) | README exists but needs final validation counts and defense notes. |

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
1. Update PROJECT_STATUS.md if the global phase/status changed.
2. Update the relevant file in project-status/.
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

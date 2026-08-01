# Project Status - ELK-bank_transactions

This file is the general project tracker. Each phase has its own detailed status file in [`project-status/`](project-status/).

Update this file and the relevant phase file before each meaningful commit.

## Current Phase

**Phase 2 - Elasticsearch mappings** is the next validation phase.

Phase 1 ingestion is validated, and the acceptance count now matches exactly. The next step is to validate Elasticsearch mappings, then create Kibana data views.

## Status Legend

| Status | Meaning |
| --- | --- |
| Done | The phase is finished and verified. |
| Base done | The main files or structure exist, but final validation is still needed. |
| In progress | Work is currently happening in this phase. |
| Not started | No meaningful work has started yet. |
| Partial | Some work exists, but the phase is clearly incomplete. |

## Progress Overview

| Phase | Status | Details | Short Notes |
| --- | --- | --- | --- |
| 0. Project structure | Done | [phase-00-project-structure.md](project-status/phase-00-project-structure.md) | Repository structure exists and the generator/logs folders are at project root. |
| 1. Logstash ingestion | Done | [phase-01-logstash-ingestion.md](project-status/phase-01-logstash-ingestion.md) | Three sources are parsed and routed correctly after the transaction parsing fix. |
| 2. Elasticsearch mappings | **In progress** | [phase-02-elasticsearch-mappings.md](project-status/phase-02-elasticsearch-mappings.md) | Explicit templates exist and need final mapping validation. |
| 3. Acceptance count | Done | [phase-03-acceptance-count.md](project-status/phase-03-acceptance-count.md) | Validated: indexed documents equal generated lines. |
| 4. Kibana data views | Not started | [phase-04-kibana-data-views.md](project-status/phase-04-kibana-data-views.md) | Data views need to be created in Kibana. |
| 5. Kibana dashboard | Not started | [phase-05-kibana-dashboard.md](project-status/phase-05-kibana-dashboard.md) | Dashboard must answer the 8 business questions. |
| 6. Kibana alert | Not started | [phase-06-kibana-alert.md](project-status/phase-06-kibana-alert.md) | Fraud alert must write to `alerts`. |
| 7. Export saved objects | Not started | [phase-07-export-saved-objects.md](project-status/phase-07-export-saved-objects.md) | Export dashboard/rule to `kibana/dashboard.ndjson`. |
| 8. Final README and demo rehearsal | Partial | [phase-08-final-readme-demo.md](project-status/phase-08-final-readme-demo.md) | README exists but needs final validation counts and defense notes. |

## Next Actions

Next validation commands:

```bash
curl -s 'http://localhost:9200/bank-transactions-*/_mapping?pretty'
curl -s 'http://localhost:9200/bank-auth-*/_mapping?pretty'
curl -s 'http://localhost:9200/bank-atm-*/_mapping?pretty'
```

Validated count from `GET _cat/indices?v`:

```text
bank-atm-2026.07.26            754
bank-auth-2026.07.26          2960
bank-deadletter-2026.08.01     170
bank-transactions-2026.07.26  4888
total                         8772
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

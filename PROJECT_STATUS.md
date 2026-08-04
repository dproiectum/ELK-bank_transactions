# Project Status - ELK-bank_transactions

This file is the general project tracker. Each phase has its own detailed status file in [`project-status/`](project-status/).

Update this file and the relevant phase file before each meaningful commit.

## Current Phase

**Phase 5 - Kibana dashboard final review** is the current phase.

Phase 1 ingestion, Phase 2 mappings, Phase 3 acceptance count, Phase 4 Kibana data views, and Phase 7 saved-object export are validated. The current work is final review of the dashboard and alert configuration before the final README/demo phase.

Latest dashboard checkpoint:

```text
Dashboard: Dashboard banking transactions
Saved panels: 16
Covered: Q1, Q3, Q4, Q5, Q6, Q7, Q8
Review note: Q2 panel exists, but the exported query groups by status only, not by time.
Export: kibana/dashboard.ndjson contains dashboard, 4 data views, and 2 alert rules.
Alert review note: exported alert rules are present and have succeeded runs, but are exported as disabled and without actions.
```

Note: `generator/generate.py` is kept unchanged from the provided `bank-transactions` kit. Batch logs start on `2026-07-26`, so Kibana must use an absolute time range including that date.

Latest validated seed:

```text
generated lines: 8772
indexed business docs: 8602
dead-letter docs: 170
total indexed docs: 8772
```

Docker startup is infrastructure-only: `docker compose up -d` creates/starts the ELK containers and does not generate log lines. Both batch and continuous log generation remain manual user actions.

Continuous generation remains manual: run `python3 generator/generate.py` only when real-time simulation is needed. Do not use continuous mode for the fixed acceptance count.

Cleaning is split by intent:

```text
scripts/clean-logs.sh     deletes generated log files
scripts/clean-indices.sh  deletes project Elasticsearch indices
scripts/seed.sh           resets logs and project indices; does not generate logs
scripts/stream.sh         starts continuous generation with a clear message
scripts/shift-log-window.py optionally spreads generated timestamps from 2026-07-27 through yesterday
```

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
| 2. Elasticsearch mappings | Done | [phase-02-elasticsearch-mappings.md](project-status/phase-02-elasticsearch-mappings.md) | Explicit mappings are validated on the real indices. |
| 3. Acceptance count | Done | [phase-03-acceptance-count.md](project-status/phase-03-acceptance-count.md) | Validated: indexed documents equal generated lines. |
| 4. Kibana data views | Done | [phase-04-kibana-data-views.md](project-status/phase-04-kibana-data-views.md) | Data views were created through the Kibana API. |
| 5. Kibana dashboard | **In progress** | [phase-05-kibana-dashboard.md](project-status/phase-05-kibana-dashboard.md) | 16 panels exported covering Q1-Q8; Q2 should be reviewed because it is not grouped over time. |
| 6. Kibana alert | Base done | [phase-06-kibana-alert.md](project-status/phase-06-kibana-alert.md) | 2 alert rules exported with successful runs; verify enabled state/action behavior before final demo. |
| 7. Export saved objects | Done | [phase-07-export-saved-objects.md](project-status/phase-07-export-saved-objects.md) | `kibana/dashboard.ndjson` contains dashboard, data views, and alert rules. |
| 8. Final README and demo rehearsal | Partial | [phase-08-final-readme-demo.md](project-status/phase-08-final-readme-demo.md) | README exists but needs final validation counts and defense notes. |

## Next Actions

Next action:

Finish final review by adjusting Q2 to be truly over time, confirming alert enabled/action behavior, and adding final proof/screenshots for the README.

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
python3 generator/generate.py --batch 5000
```

Reset logs and indices:

```bash
./scripts/seed.sh
```

Clean logs and indices separately:

```bash
./scripts/clean-logs.sh
./scripts/clean-indices.sh
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

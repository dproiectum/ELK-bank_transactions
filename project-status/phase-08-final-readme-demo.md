# Phase 8 - Final README And Demo Rehearsal

## Status

Partial.

## Goal

Make the repository understandable and reproducible for grading and GitHub readers.

Last updated: 2026-08-04.

Current project position:

```text
Phases 0-4 are validated.
Phases 5-7 have a working base.
Phase 8 will be completed together with the final report.
```

## Done

- README exists.
- Architecture is documented.
- Run commands are documented.
- Choices and trade-offs section exists.

## Remaining Work

- Add final acceptance counts.
- Add screenshots or proof for dashboard and alert.
- Confirm the two-command run path:

```bash
docker compose up -d
./scripts/seed.sh
python3 generator/generate.py --batch 5000
```

- Rehearse the defense flow:

```text
start stack -> reset project -> generate data manually -> show dashboard -> trigger/show alert -> explain choices
```

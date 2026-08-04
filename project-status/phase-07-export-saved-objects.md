# Phase 7 - Export Saved Objects

## Status

Done.

## Goal

Export Kibana saved objects so the dashboard can be imported during grading.

Last updated: 2026-08-04.

## Required Output

```text
kibana/dashboard.ndjson
```

## Export Contents

Validated contents:

```text
1 dashboard: Dashboard banking transactions
4 data views: bank-transactions-*, bank-auth-*, bank-atm-*, bank-deadletter-*
2 alert rules: High-value suspected fraud detection, High ATM withdrawal error rate
```

The original downloaded export is also kept at `kibana/export/export.ndjson`.

## Remaining Work

- Optional: test import on a fresh stack if time allows.

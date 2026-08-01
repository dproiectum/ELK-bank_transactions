# Phase 4 - Kibana Data Views

## Status

Not started.

## Goal

Create Kibana data views for all indices needed by the dashboard and alert.

## Required Data Views

```text
bank-transactions-*
bank-auth-*
bank-atm-*
bank-deadletter-*
alerts*
```

Use `@timestamp` as the time field where available.

## Remaining Work

- Create data views in Kibana.
- Confirm fields appear with the expected types.
- Confirm time filters show data from `2026-07-26`.

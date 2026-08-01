# Phase 4 - Kibana Data Views

## Status

Done.

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

## Created Data Views

Validated through the Kibana API:

| Title | Name | Time field |
| --- | --- | --- |
| `bank-transactions-*` | Bank Transactions | `@timestamp` |
| `bank-auth-*` | Bank Auth | `@timestamp` |
| `bank-atm-*` | Bank ATM | `@timestamp` |
| `bank-deadletter-*` | Bank Deadletter | `@timestamp` |
| `alerts*` | Alerts | `@timestamp` |

## Remaining Work

- None for data view creation.
- During dashboard work, confirm time filters include the generated dates. `Last 8 days` should work because batch logs cover the last 7 days.

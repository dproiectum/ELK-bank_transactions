# Phase 5 - Kibana Dashboard

## Status

Base done - to perfect.

Last updated: 2026-08-04.

## Goal

Build one dashboard answering the 8 business questions from the bank-transactions kit.

## Required Questions

1. Transaction volume and value over time, by currency.
2. Approval rate over time.
3. Top 10 merchants by transaction value.
4. Top decline reasons.
5. Card-present vs card-not-present split, per country.
6. ATM cities dispensing the most cash, plus ATM error rate.
7. Fraud attack: when, from which country, and signature.
8. Share of unparseable lines today.

## Fraud Signature To Show

The generator creates an anomaly:

```text
country=US
card_present=false
status=declined
reason=suspected_fraud
matching auth failures from IPs around 181.214.200-210.x
```

Interpretation for the dashboard:

```text
Transactions show the business signature:
country=US, card_present=false, status=declined, reason=suspected_fraud, high amount.

Auth logs confirm the technical/network signature:
web authentication failures from IPs around 181.214.200.x to 181.214.210.x.
```

## Current Dashboard Checkpoint

Kibana saved dashboard:

```text
Dashboard banking transactions
Saved panels: 16
```

Current panel coverage:

| Question | Status | Current panel / note |
| --- | --- | --- |
| Q1. Transaction volume and value over time, by currency | Covered | Transaction value by day/currency and transaction count by day/currency. |
| Q2. Approval rate over time | Base covered - to perfect | Current panel shows approved vs declined split. Improve it by grouping the rate over time if needed. |
| Q3. Top 10 merchants by transaction value | Covered | Top merchants by `SUM(amount)`. |
| Q4. Top decline reasons | Covered | Declined transactions by `reason`. |
| Q5. Card-present vs card-not-present split, per country | Covered | Country by computed `card_type`. |
| Q6. ATM cities dispensing most cash, plus ATM error rate | Covered | Cash dispensed by city and ATM error rate panels exist. |
| Q7. Fraud attack: when, country, signature | Covered | Multiple fraud investigation panels exist, including time window, country, amount percentile, card-present split, and auth geography. |
| Q8. Share of unparseable lines today | Covered | Dead-letter share panel exists. |

## Remaining Refinement

- Improve Q2 so the approval rate is shown over time, if this is useful for the final report.
- Review panel titles so each one maps clearly to a project question.
- Review dashboard layout and readability.
- Add a dashboard screenshot to the README when final.

## Continuous Demonstration Option

For a real-time ingestion demonstration, manually run:

```bash
python3 generator/generate.py
```

This continuously writes logs with current timestamps. Use it only when you want to demonstrate Logstash ingesting new events while the stack is running.

Do not use continuous mode for the fixed acceptance count, because generated line counts keep increasing.

## Panel Plan

The detailed panel plan is documented in [`kibana/DASHBOARD_PLAN.md`](../kibana/DASHBOARD_PLAN.md).

Current validated fraud signal:

```text
Declined card-not-present transactions: 454
US declined card-not-present transactions: 326
suspected_fraud reason: 352
Auth failures concentrate in IP prefixes 181.214.200.x to 181.214.210.x.
```

# Phase 5 - Kibana Dashboard

## Status

In progress.

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

## Remaining Work

- Rerun `./scripts/seed.sh 5000` after the batch timestamp change.
- Set Kibana's time range to `Last 8 days`.
- Use 1-hour or 12-hour intervals for time charts so the 7-day distribution is readable.
- Create dashboard panels.
- Make sure each panel answers a specific question.
- Add a screenshot to the README when final.

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
Declined card-not-present transactions: 455
US declined card-not-present transactions: 335
suspected_fraud reason: 357
Auth failures concentrate in IP prefixes 181.214.200.x to 181.214.210.x.
```

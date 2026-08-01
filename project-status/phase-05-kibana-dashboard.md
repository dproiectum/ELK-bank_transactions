# Phase 5 - Kibana Dashboard

## Status

Not started.

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

- Create dashboard panels.
- Make sure each panel answers a specific question.
- Add a screenshot to the README when final.

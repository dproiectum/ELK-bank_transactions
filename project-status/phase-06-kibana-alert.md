# Phase 6 - Kibana Alert

## Status

Done.

## Goal

Create an alert that catches the generated fraud anomaly.

Last updated: 2026-08-04.

## Required Alert

Condition:

```text
More than 20 declined card-not-present transactions within 5 minutes.
```

Filter:

```text
status: declined
card_present: false
```

Action:

```text
Write to an alerts index.
```

## Alert Checkpoint

Two alert rules are exported in `kibana/dashboard.ndjson`:

```text
High-value suspected fraud detection
High ATM withdrawal error rate
```

Both exported rules include successful run history.

## Optional Improvements

- Re-enable rules in Kibana if needed before the demo.
- Confirm whether the project requires explicit action output to an `alerts` index or whether Kibana's internal alert documents are sufficient.
- Add proof/screenshot to README.

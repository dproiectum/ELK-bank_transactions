# Phase 6 - Kibana Alert

## Status

Not started.

## Goal

Create an alert that catches the generated fraud anomaly.

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

## Remaining Work

- Create the Kibana rule.
- Trigger it with generated data.
- Confirm documents appear in `alerts`.
- Add proof/screenshot to README.

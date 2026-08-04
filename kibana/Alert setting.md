

### Kibana Alerting

Two Elasticsearch query rules were implemented and enabled:

| Rule | Purpose | Schedule | Status |
|---|---|---:|---|
| High-value suspected fraud detection | Detects bursts of high-value transactions declined for `suspected_fraud` from the US | Every 1 minute | Enabled and successfully executed |
| High ATM withdrawal error rate | Detects an abnormal number of failed ATM withdrawal operations | Every 1 minute | Enabled and successfully executed |

Both rules show a **100% execution success rate**, confirming that the alerting configuration is operational.
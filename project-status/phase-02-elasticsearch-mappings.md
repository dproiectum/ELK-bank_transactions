# Phase 2 - Elasticsearch Mappings

## Status

Done.

## Goal

Use explicit mappings for all business indices. Dynamic accidental mappings should not decide important field types.

## Done

Index templates exist for:

```text
bank-transactions-*
bank-auth-*
bank-atm-*
bank-deadletter-*
alerts*
```

Important field choices:

| Field | Type | Reason |
| --- | --- | --- |
| `amount` | `double` | Needed for sums and averages. |
| `card_present` | `boolean` | Needed for fraud filtering. |
| `country`, `currency`, `merchant`, `status`, `reason` | `keyword` | Needed for filters, terms aggregations, and splits. |
| `client_ip` | `ip` | Needed for IP analysis and GeoIP enrichment. |
| `geoip.location` | `geo_point` | Needed for map visualizations. |
| `@timestamp` | `date` | Needed for time-series dashboards and alerts. |

## Validated Mappings

The real Elasticsearch indices were checked after ingestion.

Transactions:

```text
@timestamp      date
amount          double
card_present    boolean
country         keyword
currency        keyword
merchant        keyword
reason          keyword
status          keyword
transaction_id  keyword
dynamic         false
```

Auth:

```text
@timestamp       date
client_ip        ip
geoip.location   geo_point
channel          keyword
result           keyword
user_id          keyword
dynamic          false
```

ATM:

```text
@timestamp  date
amount      double
atm_id      keyword
city        keyword
op          keyword
result      keyword
dynamic     false
```

Dead-letter:

```text
@timestamp          date
deadletter_reason   keyword
path                keyword
raw_line            keyword
message             text
tags                keyword
dynamic             false
```

## Remaining Work

- Confirm dashboard panels use mapped fields correctly.

## Related Files

- [`elasticsearch/mappings/bank-transactions-template.json`](../elasticsearch/mappings/bank-transactions-template.json)
- [`elasticsearch/mappings/bank-auth-template.json`](../elasticsearch/mappings/bank-auth-template.json)
- [`elasticsearch/mappings/bank-atm-template.json`](../elasticsearch/mappings/bank-atm-template.json)
- [`elasticsearch/mappings/bank-deadletter-template.json`](../elasticsearch/mappings/bank-deadletter-template.json)
- [`elasticsearch/mappings/alerts-template.json`](../elasticsearch/mappings/alerts-template.json)

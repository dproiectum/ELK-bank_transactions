# Kibana Dashboard Plan - Meridian Pay

This file describes the dashboard panels to build in Kibana for the final project. Each panel maps directly to one of the 8 required business questions.

Set the global time range to include the generated logs:

```text
2026-07-26 00:00:00 to 2026-07-27 00:00:00
```

Batch mode uses the timestamps produced by the provided generator. Continuous mode uses current timestamps. The generated batch is short, so use a small interval such as seconds or 1 minute when a time chart looks compressed.

## Data Views

| Data view | Main use |
| --- | --- |
| `bank-transactions-*` | Transactions, approval rate, merchants, fraud |
| `bank-auth-*` | Authentication failures and IP/GeoIP enrichment |
| `bank-atm-*` | ATM cash and error rate |
| `bank-deadletter-*` | Unparseable line share |
| `alerts*` | Alert output |

## Panel 1 - Transaction Volume And Value By Currency

Question:

```text
Transaction volume (count) and value (sum) over time, by currency?
```

Data view:

```text
bank-transactions-*
```

Suggested visualization:

```text
Lens line or bar chart
```

Configuration:

```text
X-axis: @timestamp date histogram
Break down by: currency
Metrics:
  - Count of records
  - Sum(amount)
```

## Panel 2 - Approval Rate Over Time

Question:

```text
What is the approval rate over time?
```

Data view:

```text
bank-transactions-*
```

Suggested visualization:

```text
Lens area/line chart
```

Configuration:

```text
X-axis: @timestamp date histogram
Break down by: status
Metric: Count of records
```

Optional formula:

```text
count(kql='status: approved') / count()
```

## Panel 3 - Top 10 Merchants By Transaction Value

Question:

```text
Top 10 merchants by transaction value?
```

Data view:

```text
bank-transactions-*
```

Suggested visualization:

```text
Horizontal bar chart
```

Configuration:

```text
Y-axis: Top values of merchant, size 10
Metric: Sum(amount)
Sort: Sum(amount), descending
```

## Panel 4 - Top Decline Reasons

Question:

```text
What are the top decline reasons?
```

Data view:

```text
bank-transactions-*
```

Filter:

```text
status: declined
```

Suggested visualization:

```text
Donut chart or horizontal bar chart
```

Configuration:

```text
Break down by: reason
Metric: Count of records
```

Validated result from the current batch:

```text
suspected_fraud       352
wrong_pin              38
insufficient_funds     33
expired_card           31
```

## Panel 5 - Card-Present Split Per Country

Question:

```text
Card-present vs card-not-present split, per country?
```

Data view:

```text
bank-transactions-*
```

Suggested visualization:

```text
Stacked bar chart
```

Configuration:

```text
X-axis: country
Break down by: card_present
Metric: Count of records
```

## Panel 6 - ATM Cash And Error Rate

Question:

```text
Which cities' ATMs dispense the most cash, and what is the ATM error rate?
```

Data view:

```text
bank-atm-*
```

Cash panel:

```text
Visualization: Horizontal bar chart
Y-axis: Top values of city
Metric: Sum(amount)
Filter: op: withdrawal and result: ok
```

Error-rate panel:

```text
Visualization: Metric or stacked bar chart
Metric formula: count(kql='result != ok') / count()
Break down by: city if using a bar chart
```

## Panel 7 - Fraud Attack Signature

Question:

```text
At some point, something that looks like a fraud attack happened. When, from which country, and what is its signature?
```

Data view:

```text
bank-transactions-*
```

Suggested visualization:

```text
Line chart plus a table
```

Fraud filter:

```text
status: declined and card_present: false
```

Useful breakdowns:

```text
country
reason
```

Validated result from the current batch:

```text
Declined card-not-present transactions: 454
US declined card-not-present transactions: 326
suspected_fraud reason: 352
```

Interpretation:

```text
The fraud signature is a burst of declined card-not-present transactions, mainly from the US, mostly marked suspected_fraud.
```

Optional auth companion panel:

```text
Data view: bank-auth-*
Filter: result: failure
Breakdown: client_ip prefixes around 181.214.200.x to 181.214.210.x
```

Validated auth signal:

```text
Authentication failures concentrate in the 181.214.200.x to 181.214.210.x IP range.
```

## Panel 8 - Dead-Letter Share

Question:

```text
What share of lines were unparseable today?
```

Data views:

```text
bank-transactions-*
bank-auth-*
bank-atm-*
bank-deadletter-*
```

Simple panel:

```text
Visualization: Metric
Value: Count of records in bank-deadletter-*
```

Validated current value:

```text
dead-letter documents: 170
generated lines: 8772
dead-letter share: 170 / 8772 = 1.94%
```

Breakdown panel:

```text
Data view: bank-deadletter-*
Visualization: Bar chart
Break down by: deadletter_reason
Metric: Count of records
```

Validated reasons:

```text
invalid_transaction_line  112
invalid_auth_line          57
csv_header                  1
```

## Dashboard Layout Recommendation

Use this order:

```text
1. KPI row: total transactions, total value, approval rate, dead-letter share
2. Operations row: volume/value over time, approval over time
3. Business row: top merchants, decline reasons, card-present split
4. ATM row: cash dispensed by city, ATM error rate
5. Fraud row: fraud timeline, fraud country/reason table, auth failure IP signal
```

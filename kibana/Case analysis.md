
# Note :

    I set the time periode from **25/07/2026 to 31/07/2027**

# 1. Transaction volume (count) and value (sum) over time, by currency 

Transactions count over time, by currency

```
FROM bank-*
| STATS
    transaction_count = COUNT(*)
    //transaction_value = SUM(amount)
  BY date = BUCKET(@timestamp, 1h), currency
| SORT date ASC, currency ASC
```


Transactions value over time, by currency

```
FROM bank-*
| STATS
    //transaction_count = COUNT(*),
    transaction_value = SUM(amount)
  BY date = BUCKET(@timestamp, 1h), currency
| SORT date ASC, currency ASC
```

# 2. What is the approval rate (approved vs declined) over time?

ES|QL

```
FROM bank-transactions-*
| WHERE status IN ("approved", "declined")
| STATS transaction_count = COUNT(*) BY status
| SORT transaction_count DESC
```



# 3. Top 10 merchants by transaction value?

ES|QL

```
FROM bank-transactions-*
| STATS
    transaction_value = SUM(amount)
  BY merchant
| SORT transaction_value DESC
| LIMIT 10
```



# 4. What are the top decline reasons?


ES|QL

```
FROM bank-transactions-*
| WHERE status == "declined"
| STATS declined_count = COUNT(*) BY reason
| SORT declined_count DESC
```



# 5. Card-present vs card-not-present split, per country?

ES|QL
```
FROM bank-transactions-*
| EVAL card_type = CASE(
    card_present == true, "Card-present",
    "Card-not-present"
)
| STATS
    transaction_count = COUNT(*)
  BY country, card_type
| SORT country ASC, transaction_count DESC
```



# 6. Which cities' ATMs dispense the most cash, and what is the ATM error rate?

## First, we need to know the how many types of Operation of an ATM :

ES|QL
```
FROM bank-atm-*
| STATS operation_count = COUNT(*) BY op
| SORT operation_count DESC
```

Result

| | op | operation_count |
|---|---|---|
| **1** | withdrawal | 754 |
| **2** | balance | 380 |
| **3** | deposit | 374 |




## Cities with the Highest Cash Dispensed by ATMs

```
FROM bank-atm-*
| WHERE op == "withdrawal" AND result == "ok"
| STATS cash_dispensed = SUM(amount) BY city
| SORT cash_dispensed DESC
```
	
Result
| | city | cash_dispensed |
|---|---|---|
| **1** | Marseille | 113,340 |
| **2** | Nantes | 112,000 |
| **3** | Paris | 108,060 |
| **4** | Lille | 106,340 |
| **5** | Lyon | 106,060 |
| **6** | Bordeaux | 102,000 |

fdsfds


## ATM error rate

```
FROM bank-atm-*
| WHERE op == "withdrawal"
| EVAL is_error = CASE(result != "ok", 1, 0)
| STATS
    total_withdrawals = COUNT(*),
    withdrawal_errors = SUM(is_error)
  BY city
| EVAL atm_error_rate = ROUND(
    withdrawal_errors * 100.0 / total_withdrawals,
    2
  )
| KEEP city, total_withdrawals, withdrawal_errors, atm_error_rate
| SORT atm_error_rate DESC
```


# 7. Fraud attack investigation


## 7.1. When it happens ?
```
FROM bank-transactions-*
| STATS transaction_count = COUNT(*) BY minute = BUCKET(@timestamp, 5 minutes)
| SORT minute ASC
```

## 7.2. Involved countries in the detected suspected fraud

2 situations fraud: detected or succesful fraud

Detected meaning **status == "declined"**
And the giving reason is ""**suspected_fraud**"

```
FROM bank-transactions-*
| WHERE status == "declined"
  AND reason == "suspected_fraud"
| STATS suspected_fraud_transactions = COUNT(*) BY country
| SORT suspected_fraud_transactions DESC
```

<br>

But it may have some potential succesful fraud




## 7.3. Signature investigation


### Percentile analysis
```
FROM bank-transactions-*
| EVAL category =
    CASE(
        status == "approved", "approved",
        status == "declined" AND reason == "suspected_fraud", "suspected_fraud",
        "other"
    )
| WHERE category != "other"
| STATS
    p50 = PERCENTILE(amount, 50),
    p90 = PERCENTILE(amount, 90),
    p95 = PERCENTILE(amount, 95),
    p99 = PERCENTILE(amount, 99),
    max_amount = MAX(amount)
  BY category
```

| Metric | Approved Transactions | Suspected Fraud Transactions | Interpretation |
|--------|----------------------:|-----------------------------:|----------------|
| **P50 (Median)** | €69.22 | €1.22k | A typical suspected fraud transaction is approximately **18× higher** than a typical approved transaction. |
| **P90** | €875.40 | €2.24k | 90% of suspected fraud transactions remain significantly higher than normal approved transactions. |
| **P95** | €1.16k | €2.35k | While **95% of approved transactions are below €1.16k**, suspected fraud transactions reach **€2.35k** at the same percentile. |
| **P99** | €1.48k | €2.48k | Even the highest-value approved transactions remain below the majority of suspected fraud transactions. |
| **Maximum** | €1.58k | €2.50k | The maximum amount observed in suspected fraud transactions exceeds the maximum approved transaction amount. |

**Conclusion:**  
The percentile analysis reveals a clear separation between approved and suspected fraud transactions. The median amount of suspected fraud transactions (€1.22k) already exceeds the 95th percentile of approved transactions (€1.16k), indicating that **high-value payments are a strong characteristic of the detected fraud pattern**.



### Most Fraud count by merchant, involved country & present of card or not

```
FROM bank-transactions-*
| WHERE amount > 1160
  AND status == "declined"
  AND reason == "suspected_fraud"
| STATS fraud_count = COUNT(*)
  BY merchant, country, card_present
  | SORT fraud_count DESC

```


This graphique helps to frame the case.
By observing the result, we will focus on the US & card non present

### Time window

```
FROM bank-transactions-*
| WHERE amount > 1160
  AND status == "declined"
  AND reason == "suspected_fraud"
  AND country == "US"
| STATS fraud_count = COUNT(*)
  BY time = BUCKET(@timestamp, 1 s)
| SORT time ASC
```

Zoom in :
- begin : Jul 26, 2026 @ 02:00:15.000
- end : Jul 26, 2026 @ 02:02:55.000


### Card present vs Card not presnet

```
FROM bank-transactions-*
| WHERE amount > 1160
  AND status == "declined"
  AND reason == "suspected_fraud"
  AND country == "US"
| EVAL payment_type = CASE(
    card_present == true, "Card Present",
    "Card Not Present"
  )
| STATS fraud_count = COUNT(*) BY payment_type
| SORT fraud_count DESC
```

### Authentification by country on this time window

```
FROM bank-auth-*
| WHERE @timestamp >= TO_DATETIME("2026-07-26T00:00:00Z")
  AND @timestamp < TO_DATETIME("2026-07-26T03:00:00Z")
| STATS auth_count = COUNT(*) BY `geoip.country_name`
| SORT auth_count DESC
```




# 8. What share of lines were unparseable (dead-letter) today?
















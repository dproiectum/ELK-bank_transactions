#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GENERATOR_DIR="$ROOT_DIR/generator"
LOG_DIR="$ROOT_DIR/logs"
BATCH="${1:-5000}"

mkdir -p "$LOG_DIR"

before_transactions=0
before_auth=0
before_atm=0
[[ -f "$LOG_DIR/transactions.log" ]] && before_transactions=$(wc -l < "$LOG_DIR/transactions.log")
[[ -f "$LOG_DIR/auth.log" ]] && before_auth=$(wc -l < "$LOG_DIR/auth.log")
[[ -f "$LOG_DIR/atm.csv" ]] && before_atm=$(wc -l < "$LOG_DIR/atm.csv")
before_total=$((before_transactions + before_auth + before_atm))

python3 "$GENERATOR_DIR/generate.py" --batch "$BATCH"

after_transactions=$(wc -l < "$LOG_DIR/transactions.log")
after_auth=$(wc -l < "$LOG_DIR/auth.log")
after_atm=$(wc -l < "$LOG_DIR/atm.csv")
after_total=$((after_transactions + after_auth + after_atm))

added_transactions=$((after_transactions - before_transactions))
added_auth=$((after_auth - before_auth))
added_atm=$((after_atm - before_atm))
added_total=$((after_total - before_total))

echo "wrote $added_total lines into $LOG_DIR/"
printf "  %-18s +%5d  total=%5d\n" "transactions.log" "$added_transactions" "$after_transactions"
printf "  %-18s +%5d  total=%5d\n" "auth.log" "$added_auth" "$after_auth"
printf "  %-18s +%5d  total=%5d\n" "atm.csv" "$added_atm" "$after_atm"
echo
echo "Wait 10-20 seconds, then check indexed counts with:"
echo "curl -s 'http://localhost:9200/_cat/indices/bank-*?h=index,docs.count' | sort"

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GENERATOR_DIR="$ROOT_DIR/generator"
LOG_DIR="$ROOT_DIR/logs"
BATCH="${1:-5000}"

mkdir -p "$LOG_DIR"
rm -f "$LOG_DIR/transactions.log" "$LOG_DIR/auth.log" "$LOG_DIR/atm.csv"

curl -s -XDELETE 'http://localhost:9200/bank-transactions-*' >/dev/null || true
curl -s -XDELETE 'http://localhost:9200/bank-auth-*' >/dev/null || true
curl -s -XDELETE 'http://localhost:9200/bank-atm-*' >/dev/null || true
curl -s -XDELETE 'http://localhost:9200/bank-deadletter-*' >/dev/null || true
curl -s -XDELETE 'http://localhost:9200/alerts*' >/dev/null || true

python3 "$GENERATOR_DIR/generate.py" --batch "$BATCH"

echo "Generated logs for batch=$BATCH"
echo "Expected input lines:"
wc -l "$LOG_DIR/transactions.log" "$LOG_DIR/auth.log" "$LOG_DIR/atm.csv"
echo
echo "Wait 10-20 seconds, then check indexed counts with:"
echo "curl -s 'http://localhost:9200/_cat/indices/bank-*?h=index,docs.count' | sort"

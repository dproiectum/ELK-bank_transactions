#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BATCH="${1:-5000}"
LOG_DIR="$ROOT_DIR/logs"
GENERATOR="$ROOT_DIR/generator/generate.py"

echo "Seeding ELK-bank_transactions with $BATCH transaction events..."
echo

"$ROOT_DIR/scripts/clean-logs.sh"
"$ROOT_DIR/scripts/clean-indices.sh"

echo
echo "Generating batch logs..."
python3 "$GENERATOR" --batch "$BATCH"
echo
echo "Generated input lines:"
wc -l "$LOG_DIR/transactions.log" "$LOG_DIR/auth.log" "$LOG_DIR/atm.csv"
echo
echo "Seed complete."
echo "Wait 10-20 seconds, then check Elasticsearch counts:"
echo "curl -s 'http://localhost:9200/_cat/indices/bank-*?h=index,docs.count' | sort"

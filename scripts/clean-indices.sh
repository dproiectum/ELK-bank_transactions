#!/usr/bin/env bash
set -euo pipefail

ES="${ES:-http://localhost:9200}"
PATTERNS=(
  "bank-transactions-*"
  "bank-auth-*"
  "bank-atm-*"
  "bank-deadletter-*"
  "alerts"
)

for pattern in "${PATTERNS[@]}"; do
  indices="$(curl -s "$ES/_cat/indices/$pattern?h=index" || true)"
  if [[ -z "$indices" ]]; then
    echo "No indices for $pattern"
    continue
  fi

  while IFS= read -r index; do
    [[ -z "$index" ]] && continue
    echo "Deleting $index"
    curl -s -XDELETE "$ES/$index" >/dev/null
  done <<< "$indices"
done

echo "Index cleanup complete"

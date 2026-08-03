#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT_DIR/logs"

mkdir -p "$LOG_DIR"

count_lines() {
  local total=0
  local file
  for file in "$LOG_DIR/transactions.log" "$LOG_DIR/auth.log" "$LOG_DIR/atm.csv"; do
    if [[ -f "$file" ]]; then
      total=$((total + $(wc -l < "$file")))
    fi
  done
  echo "$total"
}

start_count="$(count_lines)"
last_report=0

echo "streaming ~20 events/s into $LOG_DIR/ (Ctrl+C to stop)"

python3 "$ROOT_DIR/generator/generate.py" &
generator_pid=$!

cleanup() {
  if kill -0 "$generator_pid" 2>/dev/null; then
    kill "$generator_pid" 2>/dev/null || true
    wait "$generator_pid" 2>/dev/null || true
  fi
  current_count="$(count_lines)"
  written=$((current_count - start_count))
  echo
  echo "stopped after $written new lines"
}
trap cleanup INT TERM EXIT

while kill -0 "$generator_pid" 2>/dev/null; do
  sleep 2
  current_count="$(count_lines)"
  written=$((current_count - start_count))
  if (( written >= last_report + 100 )); then
    echo "  $written lines..."
    last_report=$written
  fi
done

wait "$generator_pid"

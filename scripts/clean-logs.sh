#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT_DIR/logs"

mkdir -p "$LOG_DIR"
rm -f "$LOG_DIR/transactions.log" "$LOG_DIR/auth.log" "$LOG_DIR/atm.csv"

echo "Deleted generated log files from $LOG_DIR"

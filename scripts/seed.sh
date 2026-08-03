#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Resetting ELK-bank_transactions to zero..."
echo

"$ROOT_DIR/scripts/clean-logs.sh"
"$ROOT_DIR/scripts/clean-indices.sh"

echo
echo "Reset complete."
echo
echo "No logs were generated."
echo "When you decide to generate a fixed batch, run:"
echo "python3 generator/generate.py --batch 5000"

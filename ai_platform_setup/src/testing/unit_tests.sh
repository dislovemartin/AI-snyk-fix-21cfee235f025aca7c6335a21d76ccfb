#!/bin/bash
set -euo pipefail

# ---------------------------
# Unit Tests Runner
# ---------------------------

echo "Running unit tests..."

# Example: Run Go unit tests
go test ./... -cover

# Example: Run Python unit tests
pytest --cov=./

echo "✅ Unit tests passed." 
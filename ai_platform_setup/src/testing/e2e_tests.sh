#!/bin/bash
set -euo pipefail

# ---------------------------
# End-to-End Tests Runner
# ---------------------------

echo "Running end-to-end tests..."

# Example: Using Cypress for E2E testing
npx cypress run

echo "✅ End-to-end tests passed." 
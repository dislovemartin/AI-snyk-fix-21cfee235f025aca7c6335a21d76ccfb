#!/bin/bash
set -euo pipefail

# ---------------------------
# Integration Tests Runner
# ---------------------------

echo "Running integration tests..."

# Example: Using docker-compose to set up test environment
docker-compose -f docker-compose.test.yml up --abort-on-container-exit --exit-code-from integration-service

echo "✅ Integration tests passed." 
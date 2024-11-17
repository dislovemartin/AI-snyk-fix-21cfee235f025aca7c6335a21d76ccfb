#!/bin/bash
set -euo pipefail

# ---------------------------
# Rollback Deployment Script
# ---------------------------

# Usage: ./rollback.sh <deployment_name> <namespace>

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <deployment_name> <namespace>"
    exit 1
fi

DEPLOYMENT_NAME="$1"
NAMESPACE="$2"

echo "Rolling back deployment ${DEPLOYMENT_NAME} in namespace ${NAMESPACE}..."

kubectl rollout undo deployment/"${DEPLOYMENT_NAME}" -n "${NAMESPACE}"

echo "✅ Deployment ${DEPLOYMENT_NAME} rolled back successfully." 
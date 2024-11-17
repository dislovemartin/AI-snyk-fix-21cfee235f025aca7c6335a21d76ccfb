#!/bin/bash
# shellcheck disable=SC1091
source "${MODULES_DIR}/logging.sh"

# ---------------------------
# Health Checks Module
# ---------------------------

health_check() {
    local service="$1"
    local timeout="${2:-300}"  # Default timeout 5 minutes

    log "INFO" "Performing health check for service: ${service}"

    # Wait for deployment to be ready
    if ! kubectl rollout status deployment "${service}" --namespace "${NAMESPACE}" --timeout="${timeout}s"; then
        handle_error "${LINENO}" "HEALTH_CHECK_FAILED" "${service}"
        return 1
    fi

    # Perform HTTP health check if applicable
    # Example: Check if service is responding on /health endpoint
    local pod
    pod=$(kubectl get pods --namespace "${NAMESPACE}" -l app="${service}" -o jsonpath="{.items[0].metadata.name}")
    if [ -z "${pod}" ]; then
        handle_error "${LINENO}" "POD_NOT_FOUND" "${service}"
        return 1
    fi

    if ! kubectl exec --namespace "${NAMESPACE}" "${pod}" -- curl -sf "http://localhost:${MONITORING_PORT}/health" > /dev/null; then
        handle_error "${LINENO}" "HTTP_HEALTH_CHECK_FAILED" "${service}"
        return 1
    fi

    # Additional health checks
    if ! curl -sf "http://localhost:${MONITORING_PORT}/metrics" > /dev/null; then
        handle_error "${LINENO}" "METRICS_HEALTH_CHECK_FAILED" "${service}"
        return 1
    fi

    log "SUCCESS" "Health check passed for service: ${service}"
    return 0
} 
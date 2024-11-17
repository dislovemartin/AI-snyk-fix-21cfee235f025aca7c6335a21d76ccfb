#!/bin/bash
set -euo pipefail

# ---------------------------
# CI/CD Pipeline Module
# ---------------------------

# Run tests in parallel with proper error handling
run_tests() {
    local test_types=("unit" "integration" "e2e")
    declare -A pids
    local failed_tests=()

    for test_type in "${test_types[@]}"; do
        ./ci/run-tests.sh "${test_type}" &
        pids[$test_type]=$!
    done

    # Wait for all tests and collect results
    for test_type in "${test_types[@]}"; do
        if ! wait "${pids[$test_type]}"; then
            failed_tests+=("${test_type}")
        fi
    done

    if [[ ${#failed_tests[@]} -gt 0 ]]; then
        log "ERROR" "Failed tests: ${failed_tests[*]}"
        handle_error "${LINENO}" "TESTS_FAILED" "CI_CD"
    fi
}

# Enhanced security scanning with retry mechanism
perform_security_scan() {
    local max_retries=3
    local retry_count=0

    while [[ $retry_count -lt $max_retries ]]; do
        if ./ci/security-scan.sh; then
            log "SUCCESS" "✅ Security scan passed"
            return 0
        fi

        retry_count=$((retry_count + 1))
        log "WARN" "Security scan attempt ${retry_count} failed, retrying..."
        sleep 5
    done

    log "ERROR" "❌ Security scan failed after ${max_retries} attempts"
    handle_error "${LINENO}" "SECURITY_SCAN_FAILED" "CI_CD"
}

# Main CI/CD Pipeline Function
ci_cd_pipeline() {
    log "INFO" "🚀 Starting CI/CD Pipeline..."

    run_tests
    perform_security_scan

    log "SUCCESS" "✅ CI/CD Pipeline completed successfully."
} 
#!/bin/bash
set -euo pipefail

# Determine script location and set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}"
CONFIG_DIR="${PROJECT_ROOT}/config"
MODULES_DIR="${PROJECT_ROOT}/modules"
RUNTIME_DIR="${PROJECT_ROOT}/runtime"
LOG_DIR="${PROJECT_ROOT}/logs"
ANALYTICS_DIR="${PROJECT_ROOT}/analytics"

# Source helper function from ai_platform_setup.sh
source_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Required file not found: $file"
        exit 1
    fi
    # shellcheck source=/dev/null
    source "$file"
}

# Source configuration and modules
source_file "${CONFIG_DIR}/development/ai_platform_setup.conf"
source_file "${MODULES_DIR}/logging.sh"
source_file "${MODULES_DIR}/error_handling.sh"
source_file "${MODULES_DIR}/health_checks.sh"
source_file "${MODULES_DIR}/disaster_recovery.sh"
source_file "${MODULES_DIR}/dependency_management.sh"

# Initialize logging
initialize_logging

# Trap errors
trap_errors

# Define deployment functions
setup_environment() {
    log "INFO" "Setting up deployment environment..."

    # Create required directories with error checking
    for dir in "${RUNTIME_DIR}" "${LOG_DIR}" "${CONFIG_DIR}" "${ANALYTICS_DIR}"; do
        if ! mkdir -p "$dir"; then
            handle_error "${LINENO}" "DIRECTORY_CREATION_FAILED" "${dir}"
            exit 1
        fi
    done

    # Setup permissions using existing function from ai_platform_setup.sh
    setup_permissions

    log "SUCCESS" "Environment setup completed"
}

validate_deployment() {
    log "INFO" "Validating deployment prerequisites..."

    # Run validation script
    if ! "${MODULES_DIR}/health_checks.sh"; then
        handle_error "${LINENO}" "VALIDATION_FAILED" "health_checks"
        return 1
    fi

    # Verify dependencies using dependency_management.sh
    for component in "${AGI_COMPONENTS[@]}"; do
        if ! verify_dependency "${component}" "${component}" "--version" "${DEPENDENCY_VERSION}"; then
            handle_error "${LINENO}" "DEPENDENCY_VERIFICATION_FAILED" "${component}"
            return 1
        fi
    done

    log "SUCCESS" "Deployment validation completed"
}

deploy_monitoring() {
    log "INFO" "Deploying monitoring stack..."

    # Deploy monitoring components using deploy_monitoring.sh
    if ! "${MODULES_DIR}/deploy_monitoring.sh"; then
        handle_error "${LINENO}" "MONITORING_DEPLOYMENT_FAILED" "monitoring"
        return 1
    fi

    log "SUCCESS" "Monitoring stack deployed"
}

perform_health_checks() {
    log "INFO" "Running post-deployment health checks..."

    # Run health checks for each component
    for service in "${AGI_COMPONENTS[@]}"; do
        if ! health_check "$service"; then
            handle_error "${LINENO}" "HEALTH_CHECK_FAILED" "${service}"
            return 1
        fi
    done

    log "SUCCESS" "Health checks passed"
}

main() {
    log "INFO" "Starting automated deployment..."

    # Verify backups before deployment
    if ! verify_backups; then
        handle_error "${LINENO}" "BACKUP_VERIFICATION_FAILED" "disaster_recovery"
        exit 1
    fi

    # Setup environment
    setup_environment

    # Validate deployment
    validate_deployment

    # Deploy monitoring stack
    deploy_monitoring

    # Run health checks
    perform_health_checks

    log "SUCCESS" "🎉 Automated deployment completed successfully!"
}

# Start execution
main "$@" 
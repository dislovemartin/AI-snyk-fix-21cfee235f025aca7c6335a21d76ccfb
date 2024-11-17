#!/bin/bash
set -euo pipefail

# Source logging module with absolute path
source "${MODULES_DIR}/logging.sh"

# ---------------------------
# Error Handling Module
# ---------------------------

# Check required directories exist
required_dirs=("${LOG_DIR}" "${RUNTIME_DIR}")
for dir in "${required_dirs[@]}"; do 
    if [[ ! -d "$dir" ]]; then
        echo "ERROR: Directory ${dir} does not exist or is not accessible."
        echo "Please ensure the directory exists and has correct permissions (755)."
        ls -ld "${dir%/*}" 2>/dev/null || echo "Parent directory does not exist"
        exit 1
    fi
    if [[ ! -w "$dir" ]]; then
        echo "ERROR: Directory ${dir} is not writable."
        ls -ld "$dir"
        exit 1
    fi
done

# Ensure required variables are set
required_vars=("LOG_DIR" "RUNTIME_DIR" "VAULT_ADDR" "VAULT_TOKEN")
for var in "${required_vars[@]}"; do
    if [ -z "${!var:-}" ]; then
        echo "ERROR: Environment variable ${var} is not set."
        exit 1
    fi
done

# Ensure uuidgen is installed
if ! command -v uuidgen &> /dev/null; then
    log "INFO" "uuidgen not found. Installing..."
    if ! sudo apt-get update && sudo apt-get install -y uuid-runtime; then
        log "ERROR" "Failed to install uuidgen."
        exit 1
    fi
fi

trap_errors() {
    trap 'handle_error "${BASH_SOURCE[0]}" ${LINENO} $? "${FUNCNAME[0]:-main}"' ERR
    set -Eeuo pipefail
}

trap_errors

handle_error() {
    local script="$1"
    local line="$2"
    local code="$3"
    local func="$4"
    
    # Generate unique error ID
    local error_id
    error_id=$(uuidgen)
    
    # Structured error logging
    log "ERROR" "Error in ${script}:${line} (${func}) with code ${code} [ID: ${error_id}]"
    
    # Capture system state
    local system_state
    system_state=$(get_system_state 2>/dev/null || echo "Unable to retrieve system state")
    
    case "${func}" in
        "deployment")
            retry_deployment
            ;;
        "validation")
            revalidate_components
            ;;
        *)
            return 1
            ;;
    esac
}

handle_deployment_error() {
    local service="$1"
    local error_id="$2"
    local environment="$3"

    log "ERROR" "Deployment failed for ${service} in ${environment} [ID: ${error_id}]"

    # Capture deployment state
    kubectl describe deployment "${service}" > "${LOG_DIR}/errors/deployment_${error_id}.log"
    kubectl logs -l app="${service}" > "${LOG_DIR}/errors/pods_${error_id}.log"

    # Notify team
    notify_admin "Deployment failed for ${service} in ${environment}"

    # Attempt rollback if in production
    if [[ "${environment}" == "production" ]]; then
        log "INFO" "Attempting rollback for ${service}"
        kubectl rollout undo deployment/"${service}"
    fi
}

generate_error_report() {
    local error_id="$1"
    local script="$2"
    local line="$3"
    local code="$4"
    local func="$5"
    local system_state="$6"
    local user="$7"
    
    mkdir -p "${LOG_DIR}/errors/${func,,}"
    
    cat > "${LOG_DIR}/errors/${func,,}/${error_id}.json" <<EOF
{
    "error_id": "${error_id}",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "script": "${script}",
    "function": "${func}",
    "line": ${line},
    "code": ${code},
    "system_state": "${system_state}",
    "user": "${user}"
}
EOF
}

# Function to notify admin about the failure
notify_admin() {
    local message="$1"
    log "INFO" "Notifying admin about the issue..."
    
    # Send Slack notification if configured
    if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
        if ! curl -X POST \
            -H 'Content-type: application/json' \
            --data "{\"text\":\"${message}\"}" \
            "${SLACK_WEBHOOK_URL}"; then
                log "WARN" "Failed to send Slack notification"
        fi
    fi

    # Send email notification if configured
    if [ -n "${ADMIN_EMAIL:-}" ]; then
        if ! echo "${message}" | mail -s "AI Platform Setup Alert" "${ADMIN_EMAIL}"; then
            log "WARN" "Failed to send email notification"
        fi
    fi
}

# AGI-specific error handling
handle_agi_failure() {
    local component="$1"
    log "WARN" "AGI component failure detected in ${component}"
    # Implement AGI-specific recovery logic
}
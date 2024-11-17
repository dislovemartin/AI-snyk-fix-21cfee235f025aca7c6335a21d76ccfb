#!/bin/bash

# ---------------------------
# Centralized Logging Module
# ---------------------------

# Log Levels
declare -A LOG_LEVELS=(
    ["DEBUG"]=0
    ["INFO"]=1
    ["WARN"]=2
    ["ERROR"]=3
    ["SUCCESS"]=4
)

# Color Codes
declare -A COLORS=(
    ["DEBUG"]="\e[34m"    # Blue
    ["INFO"]="\e[32m"     # Green
    ["WARN"]="\e[33m"     # Yellow
    ["ERROR"]="\e[31m"    # Red
    ["SUCCESS"]="\e[35m"  # Magenta
    ["NC"]="\e[0m"        # No Color
)

# Initialize logging system
initialize_logging() {
    mkdir -p "${LOG_DIR}"
    touch "${LOG_FILE}" "${LOG_JSON}"
    mkdir -p "${LOG_DIR}/errors"
    setup_log_rotation
}

setup_log_rotation() {
    sudo tee /etc/logrotate.d/ai_platform_setup > /dev/null <<EOF
${LOG_FILE} {
    size ${LOG_MAX_SIZE:-100M}
    rotate ${LOG_BACKUP_COUNT:-7}
    compress
    missingok
    notifempty
    copytruncate
}
EOF
}

# Main logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date -u "+%Y-%m-%dT%H:%M:%S.%3NZ")

    if [ "${LOG_LEVELS[$level]:-0}" -ge "${LOG_LEVELS[$CURRENT_LOG_LEVEL]:-0}" ]; then
        # Enhanced JSON logging
        printf '{\n' >> "${LOG_FILE}"
        printf '  "timestamp": "%s",\n' "${timestamp}" >> "${LOG_FILE}"
        printf '  "level": "%s",\n' "${level}" >> "${LOG_FILE}"
        printf '  "message": "%s",\n' "${message}" >> "${LOG_FILE}"
        printf '  "context": {\n' >> "${LOG_FILE}"
        printf '    "script": "%s",\n' "${BASH_SOURCE[1]:-unknown}" >> "${LOG_FILE}"
        printf '    "function": "%s",\n' "${FUNCNAME[1]:-main}" >> "${LOG_FILE}"
        printf '    "pid": %d\n' "$$" >> "${LOG_FILE}"
        printf '  }\n' >> "${LOG_FILE}"
        printf '}\n' >> "${LOG_FILE}"

        # Console output
        echo -e "${COLORS[$level]}${timestamp} [${level}] ${message}${COLORS["NC"]}" >&2
    fi
}

log_bug_event() {
    local issue_id="$1"
    local status="$2"
    local details="$3"
    local timestamp
    timestamp=$(date "+%Y-%m-%dT%H:%M:%S%z")

    # Log to bug tracking file
    cat <<EOF >> "${LOG_DIR}/bug_reports/${issue_id}.json"
{
    "timestamp": "${timestamp}",
    "status": "${status}",
    "details": ${details}
}
EOF

    # Standard logging
    log "INFO" "Bug ${issue_id}: ${status}"
} 
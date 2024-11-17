#!/bin/bash
set -euo pipefail

# ---------------------------
# Port Configuration Module
# ---------------------------

configure_ports() {
    log "INFO" "🔧 Configuring necessary ports..."

    # Example: Open port 5000 for NLP Service
    sudo ufw allow 5000/tcp

    # Open port 7000 for Transformers Service
    sudo ufw allow 7000/tcp

    # Reload firewall
    sudo ufw reload

    log "SUCCESS" "✅ Ports configured successfully."
}

configure_ports 
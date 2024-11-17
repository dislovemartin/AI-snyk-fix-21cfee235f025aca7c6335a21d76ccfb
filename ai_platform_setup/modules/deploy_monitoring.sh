#!/bin/bash
set -euo pipefail

# ---------------------------
# Deploy Monitoring Module
# ---------------------------

deploy_monitoring() {
    log "INFO" "📈 Deploying Monitoring Stack..."

    # Add Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update

    # Install Prometheus
    helm install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --set grafana.adminPassword=${GRAFANA_ADMIN_PASSWORD} \
        --set prometheus.prometheusSpec.resources.requests.memory=2Gi

    # Install Loki for log aggregation
    helm install loki grafana/loki-stack \
        --namespace logging \
        --create-namespace

    # Install OpenTelemetry Collector
    helm install otel-collector open-telemetry/opentelemetry-collector \
        --namespace observability \
        --create-namespace

    log "SUCCESS" "✅ Monitoring Stack deployed successfully."
}

deploy_monitoring

deploy_enhanced_monitoring() {
    log "INFO" "Setting up enhanced monitoring..."

    # Deploy metrics collector
    helm upgrade --install metrics-collector prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --set grafana.enabled=true \
        --set alertmanager.enabled=true

    # Configure alerts
    kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: deployment-alerts
  namespace: monitoring
spec:
  groups:
  - name: deployment
    rules:
    - alert: DeploymentReplicasMismatch
      expr: kube_deployment_spec_replicas != kube_deployment_status_replicas_available
      for: 5m
      labels:
        severity: critical
      annotations:
        description: "Deployment {{ \$labels.deployment }} replicas mismatch"
EOF

    log "SUCCESS" "Enhanced monitoring configured"
}

deploy_enhanced_monitoring
#!/bin/bash
set -euo pipefail

# ---------------------------
# Dependency Management Module
# ---------------------------

install_dependency() {
    local pkg=$1
    local cmd=$2
    local version_cmd=$3
    local desired_version=$4
    local checksum_var="${pkg}_CHECKSUM"

    if ! command -v "${cmd}" &> /dev/null; then
        log "INFO" "📦 Installing ${pkg}..."
        case "${pkg}" in
            docker)
                curl -fsSL https://get.docker.com | sh
                ;;
            kubectl)
                curl -LO "https://dl.k8s.io/release/${desired_version}/bin/linux/amd64/kubectl"
                chmod +x kubectl
                sudo mv kubectl /usr/local/bin/
                ;;
            helm)
                curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
                ;;
            rust)
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                source "$HOME/.cargo/env"
                ;;
            go)
                wget https://dl.google.com/go/${desired_version}.linux-amd64.tar.gz
                sudo tar -C /usr/local -xzf ${desired_version}.linux-amd64.tar.gz
                rm ${desired_version}.linux-amd64.tar.gz
                ;;
            python3)
                sudo apt-get update
                sudo apt-get install -y python3 python3-pip
                ;;
            vault)
                wget https://releases.hashicorp.com/vault/${desired_version}/vault_${desired_version}_linux_amd64.zip -O /tmp/vault.zip
                unzip /tmp/vault.zip -d /tmp/
                sudo mv /tmp/vault /usr/local/bin/
                rm -f /tmp/vault.zip
                ;;
            istioctl)
                curl -L https://istio.io/downloadIstio | ISTIO_VERSION="${desired_version}" sh -
                sudo mv "istio-${desired_version}/bin/istioctl" /usr/local/bin/
                rm -rf "istio-${desired_version}"
                ;;
            kfctl)
                wget "https://github.com/kubeflow/kfctl/releases/download/v${desired_version}/kfctl_v${desired_version}-0-g9a3621e_linux.tar.gz" -O /tmp/kfctl.tar.gz
                tar -xzf /tmp/kfctl.tar.gz -C /tmp/
                sudo mv /tmp/kfctl /usr/local/bin/
                rm -f /tmp/kfctl.tar.gz
                ;;
            opa)
                wget "https://github.com/open-policy-agent/opa/releases/download/v${desired_version}/opa_linux_amd64" -O /tmp/opa
                chmod +x /tmp/opa
                sudo mv /tmp/opa /usr/local/bin/
                ;;
            k9s)
                wget "https://github.com/derailed/k9s/releases/download/v${desired_version}/k9s_Linux_amd64.tar.gz" -O /tmp/k9s.tar.gz
                tar -xzf /tmp/k9s.tar.gz -C /tmp/
                sudo mv /tmp/k9s /usr/local/bin/
                rm -f /tmp/k9s.tar.gz
            ;;
            tensorflow)
                pip install tensorflow
                ;;
            *)
                log "ERROR" "❌ Unknown package: ${pkg}"
                return 1
                ;;
        esac
        verify_checksum "/usr/local/bin/${cmd}" "${!checksum_var}" || {
            log "ERROR" "❌ Checksum verification failed for ${pkg}"
            return 1
        }
        log "SUCCESS" "✅ ${pkg} installed successfully."
    }

    verify_checksum() {
        local file=$1
        local expected_checksum=$2

        if [ -z "${expected_checksum}" ]; then
            log "WARN" "⚠️ No checksum provided for ${file}. Skipping verification."
            return 0
        fi

        local actual_checksum
        actual_checksum=$(sha256sum "${file}" | awk '{print $1}')

        if [ "${actual_checksum}" != "${expected_checksum}" ]; then
            log "ERROR" "❌ Checksum verification failed for ${file}"
            return 1
        fi
        log "INFO" "✅ Checksum verification passed for ${file}"
        return 0
    }
}

# Validate and install dependencies
validate_dependencies() {
    log "INFO" "🔍 Validating and installing dependencies..."

    declare -A dependencies=(
        ["Docker"]="docker docker --version ${DOCKER_VERSION}"
        ["Kubectl"]="kubectl kubectl version --client --short ${KUBERNETES_VERSION}"
        ["Helm"]="helm helm version --short ${HELM_VERSION}"
        ["Rust"]="rust cargo --version ${RUST_VERSION}"
        ["Go"]="go go version ${GO_VERSION}"
        ["Python3"]="python3 python3 --version ${PYTHON_VERSION}"
        ["Vault"]="vault vault --version ${VAULT_VERSION}"
        ["Istioctl"]="istioctl istioctl version ${ISTIO_VERSION}"
        ["Kfctl"]="kfctl kfctl version ${KUBEFLOW_VERSION}"
        ["OPA"]="opa opa version ${OPA_VERSION}"
        ["K9s"]="k9s k9s version ${K9S_VERSION}"
        ["OpenAI-CLI"]="openai openai --version ${OPENAI_CLI_VERSION}"
        ["Datasets"]="datasets datasets --version ${DATASETS_VERSION}"
        ["Transformers"]="transformers transformers --version latest"
        ["Accelerate"]="accelerate accelerate --version latest"
        ["Evaluate"]="evaluate evaluate --version latest"
        ["Torch"]="torch torch --version latest"
        ["TensorFlow"]="tensorflow tensorflow --version latest"
    )

    for pkg in "${!dependencies[@]}"; do
        IFS=' ' read -r cmd version_cmd desired_version <<< "${dependencies[$pkg]}"
        install_dependency "${pkg}" "${cmd}" "${version_cmd}" "${desired_version}"
    done

    log "SUCCESS" "✅ All dependencies are installed and up-to-date."
} 
import requests
import re

VERSION_FILE = 'ai_platform_setup/config/development/versions.conf'

def fetch_latest_version(tool_name):
    # Placeholder function to fetch the latest version
    # Implement actual logic based on the tool
    latest_versions = {
        "DOCKER_VERSION": "20.10.7",
        "KUBERNETES_VERSION": "v1.21.0",
        # Add other tools and their latest versions
    }
    return latest_versions.get(tool_name, "latest")

def update_version(file_path, tool):
    with open(file_path, 'r') as file:
        content = file.read()
    
    pattern = rf'{tool}="\d+\.\d+\.\d+"'
    replacement = f'{tool}="{fetch_latest_version(tool)}"'
    new_content = re.sub(pattern, replacement, content)
    
    with open(file_path, 'w') as file:
        file.write(new_content)
    
    print(f"{tool} updated to {fetch_latest_version(tool)}")

def main():
    tools = [
        "DOCKER_VERSION",
        "KUBERNETES_VERSION",
        "HELM_VERSION",
        "RUST_VERSION",
        "GO_VERSION",
        "PYTHON_VERSION",
        "VAULT_VERSION",
        "ISTIO_VERSION",
        "KUBEFLOW_VERSION",
        "OPA_VERSION",
        "K9S_VERSION",
        "OPENAI_CLI_VERSION",
        "DATASETS_VERSION",
        "TRANSFORMERS_VERSION",
        "ACCELERATE_VERSION",
        "EVALUATE_VERSION",
        "TORCH_VERSION",
        "TENSORFLOW_VERSION"
    ]
    
    for tool in tools:
        update_version(VERSION_FILE, tool)

if __name__ == "__main__":
    main() 
#!/bin/bash
set -euo pipefail

# ---------------------------
# Dependency Analyzer
# ---------------------------

# Usage: ./dependency_analyzer.sh <file_or_directory>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_or_directory>"
    exit 1
fi

TARGET="$1"

echo "Analyzing dependencies for ${TARGET}..."

# Example: Using go list for Go projects
if [[ -f "${TARGET}/go.mod" ]]; then
    go list -m all > dependency_report.txt
    echo "✅ Go dependencies listed in dependency_report.txt"
elif [[ -f "${TARGET}/requirements.txt" ]]; then
    pip freeze > dependency_report.txt
    echo "✅ Python dependencies listed in dependency_report.txt"
else
    echo "No recognized dependency file found in ${TARGET}."
    exit 1
fi 
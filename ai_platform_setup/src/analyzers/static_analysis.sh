#!/bin/bash
set -euo pipefail

# ---------------------------
# Static Analysis
# ---------------------------

# Usage: ./static_analysis.sh <file_or_directory>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_or_directory>"
    exit 1
fi

TARGET="$1"

echo "Performing static analysis on ${TARGET}..."

# Example: Using ShellCheck for shell scripts
if [ -d "${TARGET}" ]; then
    find "${TARGET}" -type f -name "*.sh" | xargs shellcheck
else
    shellcheck "${TARGET}"
fi

echo "✅ Static analysis completed." 
#!/bin/bash
set -euo pipefail

# ---------------------------
# Complexity Analyzer
# ---------------------------

# Usage: ./complexity_analyzer.sh <file_or_directory>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_or_directory>"
    exit 1
fi

TARGET="$1"

echo "Analyzing complexity for ${TARGET}..."

# Example: Using lizard to analyze code complexity
if ! command -v lizard &> /dev/null; then
    echo "Installing lizard..."
    pip install lizard
fi

lizard "${TARGET}" > complexity_report.txt

echo "✅ Complexity analysis completed. Report saved to complexity_report.txt" 
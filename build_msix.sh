#!/usr/bin/env bash
set -euo pipefail

# Build script for generating the Windows MSIX package.
# Usage:
#   ./build_msix.sh [flutter build options...]
# Example:
#   ./build_msix.sh --build-name 1.0.0 --build-number 1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/prompteur"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: Flutter is not in PATH. Activate your Flutter SDK before running this script." >&2
  exit 1
fi

cd "${PROJECT_DIR}"

flutter build windows --release --packaging-type msix "$@"

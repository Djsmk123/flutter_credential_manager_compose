#!/usr/bin/env bash

# Runs flutter analyze for each Flutter/Dart package to ensure analyzer
# errors are caught before commits. Intended to be invoked by pre-commit.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PACKAGES=(
  "packages/credential_manager"
  "packages/credential_manager/example"
  "packages/credential_manager_android"
  "packages/credential_manager_ios"
  "packages/credential_manager_platform_interface"
)

for pkg in "${PACKAGES[@]}"; do
  (
    cd "${PROJECT_ROOT}/${pkg}"
    if [[ -f "pubspec.yaml" ]]; then
      echo "Running flutter analyze in ${pkg}"
      flutter analyze --no-fatal-warnings --no-fatal-infos >/dev/null
    fi
  )
done

echo "Flutter analyze completed for all packages."

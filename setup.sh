#!/bin/bash

# Trivance Platform - Workspace Setup
# Single command to configure complete development environment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exec "${SCRIPT_DIR}/scripts/core/orchestrator.sh" "$@"
else
    source "${SCRIPT_DIR}/scripts/core/orchestrator.sh" "$@"
fi
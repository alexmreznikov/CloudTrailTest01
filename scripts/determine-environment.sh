#!/bin/bash
set -euxo pipefail

# Determine deployment environment and validate parameters file exists
# Usage: ./determine-environment.sh <environment> <workspace>

SELECTED_ENV="$1"
WORKSPACE="${2:-.}"
SELECTED_PARAMS_FILE="vars/${SELECTED_ENV}.json"

if [ ! -f "${WORKSPACE}/${SELECTED_PARAMS_FILE}" ]; then
  echo "::error::Parameter file not found for environment '${SELECTED_ENV}': ${SELECTED_PARAMS_FILE}"
  exit 1
fi

# Output to GitHub environment (if running in GitHub Actions)
if [ -n "${GITHUB_ENV:-}" ]; then
  echo "ENV_KEY=${SELECTED_ENV}" >> "$GITHUB_ENV"
  echo "PARAMS_FILE=${SELECTED_PARAMS_FILE}" >> "$GITHUB_ENV"
fi

echo "Resolved environment: ${SELECTED_ENV}"
echo "Resolved params file: ${SELECTED_PARAMS_FILE}"
#!/bin/bash
set -euxo pipefail

# Verify CloudTrail is logging
# Usage: ./verify-trail-logging.sh <trail_name> <aws_region>

TRAIL_NAME="$1"
AWS_REGION="$2"

echo "--- Checking trail status ---"
STATUS_JSON=$(aws cloudtrail get-trail-status \
  --name "${TRAIL_NAME}" \
  --region "${AWS_REGION}")
echo "$STATUS_JSON" | jq .

IS_LOGGING=$(echo "$STATUS_JSON" | jq -r '.IsLogging')
if [ "$IS_LOGGING" != "true" ]; then
  echo "::error::Trail '${TRAIL_NAME}' is NOT logging (IsLogging=$IS_LOGGING)."
  exit 1
fi
echo "✓ Trail is actively logging."
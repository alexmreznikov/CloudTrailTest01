#!/bin/bash
set -euxo pipefail

# Verify CloudTrail trail exists
# Usage: ./verify-trail-exists.sh <trail_name> <aws_region>

TRAIL_NAME="$1"
AWS_REGION="$2"

echo "--- Describing trail ---"
TRAIL_JSON=$(aws cloudtrail describe-trails \
  --trail-name-list "${TRAIL_NAME}" \
  --region "${AWS_REGION}")
echo "$TRAIL_JSON" | jq .

TRAIL_COUNT=$(echo "$TRAIL_JSON" | jq '.trailList | length')
if [ "$TRAIL_COUNT" -eq 0 ]; then
  echo "::error::Trail '${TRAIL_NAME}' was NOT found."
  exit 1
fi
echo "✓ Trail exists."
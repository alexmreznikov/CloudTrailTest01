#!/bin/bash
set -euxo pipefail

# Verify trail configuration
# Usage: ./verify-trail-configuration.sh <trail_name> <aws_region> <expected_s3_bucket>

TRAIL_NAME="$1"
AWS_REGION="$2"
EXPECTED_S3_BUCKET="$3"

echo "--- Verifying trail configuration ---"
TRAIL_JSON=$(aws cloudtrail describe-trails \
  --trail-name-list "${TRAIL_NAME}" \
  --region "${AWS_REGION}")

IS_MULTI_REGION=$(echo "$TRAIL_JSON" | jq -r '.trailList[0].IsMultiRegionTrail')
INCLUDE_GLOBAL=$(echo "$TRAIL_JSON" | jq -r '.trailList[0].IncludeGlobalServiceEvents')
S3_BUCKET=$(echo "$TRAIL_JSON" | jq -r '.trailList[0].S3BucketName')
S3_PREFIX=$(echo "$TRAIL_JSON" | jq -r '.trailList[0].S3KeyPrefix')
LOG_VALIDATION=$(echo "$TRAIL_JSON" | jq -r '.trailList[0].LogFileValidationEnabled')

echo "  IsMultiRegionTrail:        $IS_MULTI_REGION"
echo "  IncludeGlobalServiceEvents: $INCLUDE_GLOBAL"
echo "  S3BucketName:              $S3_BUCKET"
echo "  S3KeyPrefix:               $S3_PREFIX"
echo "  LogFileValidationEnabled:  $LOG_VALIDATION"

ERRORS=0
if [ "$IS_MULTI_REGION" != "true" ]; then
  echo "::error::IsMultiRegionTrail is not true"
  ERRORS=$((ERRORS+1))
fi
if [ "$INCLUDE_GLOBAL" != "true" ]; then
  echo "::error::IncludeGlobalServiceEvents is not true"
  ERRORS=$((ERRORS+1))
fi
if [ "$S3_BUCKET" != "${EXPECTED_S3_BUCKET}" ]; then
  echo "::error::S3BucketName mismatch: $S3_BUCKET"
  ERRORS=$((ERRORS+1))
fi
if [ "$LOG_VALIDATION" != "true" ]; then
  echo "::error::LogFileValidationEnabled is not true"
  ERRORS=$((ERRORS+1))
fi

if [ "$ERRORS" -gt 0 ]; then
  echo "::error::Trail configuration verification failed with $ERRORS error(s)."
  exit 1
fi
echo "✓ Trail configuration verified successfully."
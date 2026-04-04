#!/bin/bash
set -euxo pipefail

# Preflight checks for referenced resources before apply/dry-run
# Usage: ./preflight-checks.sh <stack_name> <aws_region> <workspace> <params_file>

STACK_NAME="$1"
AWS_REGION="$2"
WORKSPACE="${3:-.}"
PARAMS_FILE="$4"

echo "--- Caller identity ---"
aws sts get-caller-identity

echo "--- Stack status check ---"
STACK_STATUS=$(aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --region "${AWS_REGION}" \
  --query 'Stacks[0].StackStatus' \
  --output text 2>/dev/null || echo "DOES_NOT_EXIST")

echo "Current stack status: ${STACK_STATUS}"

# Check for problematic stack states that should block deployment
case "${STACK_STATUS}" in
  UPDATE_ROLLBACK_FAILED|ROLLBACK_FAILED|DELETE_FAILED)
    echo "::error::Stack is in a failed state: ${STACK_STATUS}"
    echo "::error::Manual intervention required. Consider running cleanup action or fixing the stack manually."
    exit 1
    ;;
  REVIEW_IN_PROGRESS)
    echo "Stack is in REVIEW_IN_PROGRESS state (change set not executed yet)."
    echo "This will be treated as a new deployment."
    ;;
  *_IN_PROGRESS)
    echo "::error::Stack operation is currently in progress: ${STACK_STATUS}"
    echo "::error::Wait for the current operation to complete before retrying."
    exit 1
    ;;
  DELETE_COMPLETE|DOES_NOT_EXIST)
    echo "Stack does not exist or is deleted. Will create new stack."
    ;;
  CREATE_COMPLETE|UPDATE_COMPLETE|UPDATE_ROLLBACK_COMPLETE)
    echo "Stack is in a stable state and ready for updates."
    ;;
  *)
    echo "::warning::Unexpected stack status: ${STACK_STATUS}"
    ;;
esac

TRAIL_NAME=$(jq -r '.[] | select(.ParameterKey=="TrailName") | .ParameterValue' "${WORKSPACE}/${PARAMS_FILE}")
S3_BUCKET=$(jq -r '.[] | select(.ParameterKey=="S3BucketName") | .ParameterValue' "${WORKSPACE}/${PARAMS_FILE}")

if [ -z "${TRAIL_NAME}" ] || [ "${TRAIL_NAME}" = "null" ]; then
  echo "::error::TrailName is missing in ${PARAMS_FILE}"
  exit 1
fi
if [ -z "${S3_BUCKET}" ] || [ "${S3_BUCKET}" = "null" ]; then
  echo "::error::S3BucketName is missing in ${PARAMS_FILE}"
  exit 1
fi

echo "Checking for existing trail name collisions: ${TRAIL_NAME}"
EXISTING_COUNT=$(aws cloudtrail describe-trails \
  --trail-name-list "${TRAIL_NAME}" \
  --region "${AWS_REGION}" \
  --query 'length(trailList)' \
  --output text)
echo "Existing trail count for ${TRAIL_NAME}: ${EXISTING_COUNT}"
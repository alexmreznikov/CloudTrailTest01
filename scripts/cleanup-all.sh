#!/bin/bash
set -euxo pipefail
set -euo pipefail

# Clean up all change sets and stack
# Usage: ./cleanup-all.sh <stack_name> <aws_region>

STACK_NAME="$1"
AWS_REGION="$2"

echo "--- Deleting all change sets for stack ${STACK_NAME} ---"
CHANGESETS=$(aws cloudformation list-change-sets \
  --stack-name "${STACK_NAME}" \
  --region "${AWS_REGION}" \
  --query 'Summaries[].ChangeSetName' --output text || true)
if [ -z "$CHANGESETS" ]; then
  echo "No change sets found."
else
  for cs in $CHANGESETS; do
    echo "Deleting change set: $cs"
    aws cloudformation delete-change-set \
      --stack-name "${STACK_NAME}" \
      --change-set-name "$cs" \
      --region "${AWS_REGION}" || true
  done
fi
echo "--- Deleting stack ${STACK_NAME} (if exists) ---"
if aws cloudformation describe-stacks --stack-name "${STACK_NAME}" --region "${AWS_REGION}" >/dev/null 2>&1; then
  aws cloudformation delete-stack \
    --stack-name "${STACK_NAME}" \
    --region "${AWS_REGION}"
  echo "Waiting for stack deletion to complete..."
  aws cloudformation wait stack-delete-complete \
    --stack-name "${STACK_NAME}" \
    --region "${AWS_REGION}"
  echo "✓ Stack deleted successfully."
else
  echo "Stack ${STACK_NAME} does not exist."
fi
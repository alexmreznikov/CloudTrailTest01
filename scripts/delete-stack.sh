#!/bin/bash
set -euxo pipefail

# Delete CloudFormation stack
# Usage: ./delete-stack.sh <stack_name> <aws_region>

STACK_NAME="$1"
AWS_REGION="$2"

echo "Deleting stack ${STACK_NAME}..."
aws cloudformation delete-stack \
  --stack-name "${STACK_NAME}" \
  --region "${AWS_REGION}"

echo "Waiting for stack deletion to complete..."
aws cloudformation wait stack-delete-complete \
  --stack-name "${STACK_NAME}" \
  --region "${AWS_REGION}"

echo "✓ Stack deleted successfully."
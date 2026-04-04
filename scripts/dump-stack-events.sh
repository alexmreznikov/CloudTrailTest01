#!/bin/bash
set -euxo pipefail

# Dump CloudFormation stack events on failure
# Usage: ./dump-stack-events.sh <stack_name> <aws_region>

STACK_NAME="$1"
AWS_REGION="$2"

echo "--- Latest CloudFormation stack events ---"
aws cloudformation describe-stack-events \
  --stack-name "${STACK_NAME}" \
  --region "${AWS_REGION}" \
  --query 'StackEvents[0:25].[Timestamp,LogicalResourceId,ResourceStatus,ResourceStatusReason]' \
  --output table || true
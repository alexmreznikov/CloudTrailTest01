#!/bin/bash
set -euxo pipefail

# Show stack outputs
# Usage: ./show-stack-outputs.sh <stack_name> <aws_region>

STACK_NAME="$1"
AWS_REGION="$2"

aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --query 'Stacks[0].Outputs' \
  --output table \
  --region "${AWS_REGION}"
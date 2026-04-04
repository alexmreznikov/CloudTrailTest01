#!/bin/bash
set -euxo pipefail

# Cleanup dry-run change set
# Usage: ./cleanup-changeset.sh <stack_name> <aws_region> <change_set_name>

STACK_NAME="$1"
AWS_REGION="$2"
CHANGE_SET_NAME="$3"

aws cloudformation delete-change-set \
  --stack-name "${STACK_NAME}" \
  --change-set-name "${CHANGE_SET_NAME}" \
  --region "${AWS_REGION}" || true
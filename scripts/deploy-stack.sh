#!/bin/bash
set -euxo pipefail

# Deploy CloudFormation stack
# Usage: ./deploy-stack.sh <stack_name> <aws_region> <workspace> <template_file> <params_file> <env_key>

STACK_NAME="$1"
AWS_REGION="$2"
WORKSPACE="${3:-.}"
TEMPLATE_FILE="$4"
PARAMS_FILE="$5"
ENV_KEY="$6"

aws cloudformation deploy \
  --template-file "${WORKSPACE}/${TEMPLATE_FILE}" \
  --stack-name "${STACK_NAME}" \
  --parameter-overrides "file://${WORKSPACE}/${PARAMS_FILE}" \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset \
  --region "${AWS_REGION}"
echo "Stack deployed successfully."
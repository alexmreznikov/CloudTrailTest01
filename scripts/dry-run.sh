#!/bin/bash
set -euxo pipefail

# Preview CloudFormation changes (dry-run)
# Usage: ./dry-run.sh <stack_name> <aws_region> <workspace> <template_file> <params_file> <env_key> <change_set_name>

STACK_NAME="$1"
AWS_REGION="$2"
WORKSPACE="${3:-.}"
TEMPLATE_FILE="$4"
PARAMS_FILE="$5"
ENV_KEY="$6"
CHANGE_SET_NAME="$7"

echo "Creating non-executed change set: ${CHANGE_SET_NAME}"

STACK_STATUS=$(aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}" \
  --region "${AWS_REGION}" \
  --query 'Stacks[0].StackStatus' \
  --output text 2>/dev/null || echo "DOES_NOT_EXIST")

echo "Stack status: ${STACK_STATUS}"

if [[ "${STACK_STATUS}" == "DOES_NOT_EXIST" ]] \
    || [[ "${STACK_STATUS}" == "DELETE_COMPLETE" ]] \
    || [[ "${STACK_STATUS}" == "REVIEW_IN_PROGRESS" ]]; then
  CHANGE_SET_TYPE="CREATE"
  echo "Stack does not exist or is deleted. Using CREATE change set type."
else
  CHANGE_SET_TYPE="UPDATE"
  echo "Stack exists in active state. Using UPDATE change set type."
fi

aws cloudformation create-change-set \
  --stack-name "${STACK_NAME}" \
  --change-set-name "${CHANGE_SET_NAME}" \
  --change-set-type "${CHANGE_SET_TYPE}" \
  --template-body "file://${WORKSPACE}/${TEMPLATE_FILE}" \
  --parameters "file://${WORKSPACE}/${PARAMS_FILE}" \
  --capabilities CAPABILITY_NAMED_IAM \
  --region "${AWS_REGION}" \
  --tags \
    Key=cmdb-technical-service-offering-id,Value=CI000111111 \
    Key=ManagedBy,Value=CloudFormation \
    Key=Environment,Value="${ENV_KEY}" >/dev/null

echo "Waiting for change set creation to finish..."
if ! aws cloudformation wait change-set-create-complete \
  --stack-name "${STACK_NAME}" \
  --change-set-name "${CHANGE_SET_NAME}" \
  --region "${AWS_REGION}"; then
  STATUS=$(aws cloudformation describe-change-set \
    --stack-name "${STACK_NAME}" \
    --change-set-name "${CHANGE_SET_NAME}" \
    --region "${AWS_REGION}" \
    --query 'Status' --output text)
  REASON=$(aws cloudformation describe-change-set \
    --stack-name "${STACK_NAME}" \
    --change-set-name "${CHANGE_SET_NAME}" \
    --region "${AWS_REGION}" \
    --query 'StatusReason' --output text)

  echo "Change set status: ${STATUS}"
  echo "Reason: ${REASON}"

  # No-op updates are surfaced as FAILED with a no-changes reason.
  if echo "${REASON}" | grep -qi "didn't contain changes"; then
    echo "No infrastructure changes detected."
    exit 0
  fi

  echo "::error::Dry-run failed while creating the change set."
  exit 1
fi

echo "--- Proposed infrastructure changes ---"
aws cloudformation describe-change-set \
  --stack-name "${STACK_NAME}" \
  --change-set-name "${CHANGE_SET_NAME}" \
  --region "${AWS_REGION}" \
  --query 'Changes[*].ResourceChange.[Action,LogicalResourceId,ResourceType,Replacement]' \
  --output table
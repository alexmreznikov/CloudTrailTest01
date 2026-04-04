#!/bin/bash
set -euxo pipefail

# Validate CloudFormation template
# Usage: ./validate-template.sh <workspace> <template_file>

WORKSPACE="${1:-.}"
TEMPLATE_FILE="${2:-cloudformation/cloudtrail.yaml}"

aws cloudformation validate-template \
  --template-body "file://${WORKSPACE}/${TEMPLATE_FILE}"
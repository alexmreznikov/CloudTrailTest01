# AGENTS Guide

## Project intent
- This repo provisions one AWS CloudTrail trail in the Org Management account using AWS CloudFormation.
- The CloudFormation template lives in `cloudformation/cloudtrail.yaml`.
- Deployment ordering matters: this repo expects IAM/OIDC roles and log bucket to already exist (see `README.md`).

## Architecture and boundaries
- Entry point: `cloudformation/cloudtrail.yaml` defines the `CloudTrailTrail` resource (`AWS::CloudTrail::Trail`).
- The `EnableCloudTrailTrail` parameter + `CreateTrail` condition controls whether the trail is created (mirrors the old Terraform `count` toggle).
- Trail configuration:
  - multi-region enabled (`IsMultiRegionTrail: true`)
  - global events enabled (`IncludeGlobalServiceEvents: true`)
  - account-scoped prefix (`S3KeyPrefix: cloudtrail/${AWS::AccountId}`)
  - log file validation enabled (`EnableLogFileValidation: true`)
  - event selectors: All read/write, management events included
- Inputs are passed via parameter overrides file (`vars/prod.json`).
- Outputs are conditional on `CreateTrail`.

## Key files to modify by task
- Change CloudTrail behavior: `cloudformation/cloudtrail.yaml`.
- Change environment defaults/parameters: `vars/prod.json`.
- Change CI deploy behavior: `.github/workflows/deploy.yml`.

## Developer workflow (local)
- Standard path from `README.md`:
  - `aws cloudformation validate-template --template-body file://cloudformation/cloudtrail.yaml`
  - `aws cloudformation deploy --template-file cloudformation/cloudtrail.yaml --stack-name org-mgmt-cloudtrail-stack --parameter-overrides file://vars/prod.json --capabilities CAPABILITY_NAMED_IAM --no-fail-on-empty-changeset --region ap-southeast-2`
- To destroy:
  - `aws cloudformation delete-stack --stack-name org-mgmt-cloudtrail-stack --region ap-southeast-2`
  - `aws cloudformation wait stack-delete-complete --stack-name org-mgmt-cloudtrail-stack --region ap-southeast-2`

## CI/CD behavior to preserve
- `.github/workflows/deploy.yml` is manual (`workflow_dispatch`) with `action` input (`apply` or `destroy`).
- AWS auth is two-step role assumption: OIDC role first, then CICD role with `role-chaining: true`.
- On `apply`: deploys the CloudFormation stack, shows outputs, then verifies trail existence, logging status, and configuration.
- On `destroy`: deletes the stack and waits for completion.
- Stack-level tags are applied via `--tags` in the deploy command.

## Repo-specific conventions and pitfalls
- Tags are applied at both the stack level (in `deploy.yml`) and the resource level (in the template).
- `ServiceId` is mandatory for CMDB tagging (`cmdb-technical-service-offering-id`).
- Stack name is `org-mgmt-cloudtrail-stack`; changing this affects the deployed stack.
- The `EnableCloudTrailTrail` condition means outputs are only present when the trail is created.
- CloudFormation manages its own state — there is no external state bucket to maintain.

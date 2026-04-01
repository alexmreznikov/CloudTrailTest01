# AGENTS Guide

## Project intent
- This repo provisions one AWS CloudTrail trail in the Org Management account using Terraform.
- Root config is a thin wrapper; resource logic lives in `modules/cloudtrail-trail/`.
- Deployment ordering matters: this repo expects IAM/OIDC roles and log bucket to already exist (see `README.md`).

## Architecture and boundaries
- Entry point: `main.tf` creates `module.cloudtrail_trail` only when `var.enable_cloudtrail_trail` is true (`count` toggle pattern).
- Module resource: `modules/cloudtrail-trail/main.tf` defines `aws_cloudtrail.main` with:
  - multi-region enabled (`is_multi_region_trail = true`)
  - global events enabled (`include_global_service_events = true`)
  - account-scoped prefix (`s3_key_prefix = "cloudtrail/${data.aws_caller_identity.current.account_id}"`)
- Inputs are passed directly from root vars (`variables.tf` + `vars/prod.tfvars`); there is no `terraform_remote_state` data source in code.
- Outputs are null-safe at root (`outputs.tf`) because module uses `count`.

## Key files to modify by task
- Change CloudTrail behavior: `modules/cloudtrail-trail/main.tf`.
- Change environment defaults/toggles: `variables.tf`, `vars/prod.tfvars`.
- Change required versions/providers: `versions.tf`.
- Change state location: `backend.tf` and (if bootstrapping) `scripts/create-terraform-state-bucket.sh`.
- Change CI deploy behavior: `.github/workflows/deploy.yml`.

## Developer workflow (local)
- Standard path is from `README.md`:
  - `terraform init`
  - `terraform plan -var-file="vars/prod.tfvars"`
  - `terraform apply -var-file="vars/prod.tfvars"`
- Safe preflight checks before plan/apply:
  - `terraform fmt -recursive`
  - `terraform validate`
- If backend bucket is missing, bootstrap via `scripts/create-terraform-state-bucket.sh` (uses `TF_STATE_BUCKET` and `AWS_REGION` env overrides).

## CI/CD behavior to preserve
- `.github/workflows/deploy.yml` is manual (`workflow_dispatch`) with `action` input (`apply` or `destroy`).
- AWS auth is two-step role assumption: OIDC role first, then CICD role with `role-chaining: true`.
- Plan uses `terraform plan -detailed-exitcode`; downstream logic depends on exit codes:
  - `0` => "no changes" path
  - `2` => apply/output path
- Vars file path is injected via `${{ vars.TF_VARS_FILE_PATH }}`; keep this contract when editing workflow commands.

## Repo-specific conventions and pitfalls
- Provider-level `default_tags` in `providers.tf` are expected on all resources; module also merges extra tags.
- `serviceid` is mandatory in both root and module for CMDB tagging (`cmdb-technical-service-offering-id`).
- Keep root outputs guarded with `var.enable_cloudtrail_trail ? ... : null` to avoid index errors on `module.cloudtrail_trail[0]`.
- `backend.tf` is hard-coded to `org-mgmt-terraform-state-alexorg-local` and key `cloudtrail/terraform.tfstate`; changing this affects state migration.


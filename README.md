# CloudTrail Trail Infrastructure

This Terraform project creates CloudTrail trail resources for audit logging in the AWS Organization Management Account.

## Purpose

This project creates the CloudTrail trail configuration. It should be deployed **after** both:
1. The CloudTrailCICD01 project, which creates the IAM roles required for GitHub Actions authentication
2. The CloudTrailBucket01 project, which creates the S3 bucket for CloudTrail logs

## What it creates

- **CloudTrail Trail** - Multi-region trail that logs all AWS API activity to the S3 bucket managed by CloudTrailBucket01

## Deployment

### Prerequisites

- AWS credentials with CloudTrail permissions
- CloudTrailCICD01 project deployed (for GitHub Actions authentication)
- CloudTrailBucket01 project deployed (for S3 bucket)
- S3 bucket for Terraform state: `org-mgmt-terraform-state-alexorg-local`

### Deploy

```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan -var-file="vars/prod.tfvars"

# Apply changes
terraform apply -var-file="vars/prod.tfvars"
```

### Outputs

- CloudTrail trail ARN and name
- S3 bucket name and ARN (from remote state)

## Architecture

This project reads the S3 bucket information from the CloudTrailBucket01 project's remote state. This separation allows:
- Independent lifecycle management of bucket and trail
- Better isolation of concerns
- Ability to recreate the trail without affecting log storage

## Related Projects

- **CloudTrailCICD01** - GitHub OIDC and CICD IAM roles (must be deployed first)
- **CloudTrailBucket01** - CloudTrail S3 bucket (must be deployed before this project)

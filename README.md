# CloudTrail Infrastructure

This Terraform project creates CloudTrail resources for audit logging in the AWS Organization Management Account.

## Purpose

This project creates the CloudTrail infrastructure including S3 bucket and trail configuration. It should be deployed **after** the CloudTrailCICD01 project, which creates the IAM roles required for GitHub Actions authentication.

## What it creates

- **CloudTrail S3 Bucket** - Secure storage for CloudTrail logs with versioning and encryption
- **CloudTrail Trail** - Multi-region trail that logs all AWS API activity

## Deployment

### Prerequisites

- AWS credentials with CloudTrail and S3 permissions
- CloudTrailCICD01 project deployed (for GitHub Actions authentication)
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
- S3 bucket name and ARN

## Related Projects

- **CloudTrailCICD01** - GitHub OIDC and CICD IAM roles (must be deployed first)

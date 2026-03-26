# GitHub CICD Roles for CloudTrail Management
# This configuration creates OIDC and CICD roles for GitHub Actions
# to authenticate and manage CloudTrail in the AWS Org Management Account

module "github_cicd_cloudtrail" {
  count  = var.enable_github_cicd_roles ? 1 : 0
  source = "./modules/iam/github-cicd"

  oidc_role_name              = var.oidc_role_name
  cicd_role_name              = var.cicd_role_name
  github_org                  = var.github_org
  github_repo                 = var.github_repo
  serviceid                   = var.serviceid
  terraform_state_bucket_arn  = var.terraform_state_bucket_arn

  tags = {
    Environment = var.env_key
    Purpose     = "GitHub Actions CI/CD for CloudTrail Management"
  }
}

# Production Environment Configuration
# This is deployed to the AWS Org Management Account
serviceid = "CI000111111"
region    = "ap-southeast-2"
env_key   = "prod"

# IAM Role Names
oidc_role_name = "org-mgmt-GithubOIDCRole"
cicd_role_name = "org-mgmt-GithubCICDRole"

# Module Controls
enable_github_cicd_roles  = true
enable_cloudtrail_bucket  = true
enable_cloudtrail_trail   = true

# CloudTrail Configuration
cloudtrail_name               = "org-mgmt-cloudtrail"
cloudtrail_bucket_name        = "org-mgmt-cloudtrail-logs-alexorg-local"
cloudtrail_log_retention_days = 90

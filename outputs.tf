# GitHub CICD Roles outputs
output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = var.enable_github_cicd_roles ? module.github_cicd_cloudtrail[0].oidc_provider_arn : null
}

output "github_oidc_role_arn" {
  description = "ARN of the GitHub OIDC role for CloudTrail management"
  value       = var.enable_github_cicd_roles ? module.github_cicd_cloudtrail[0].oidc_role_arn : null
}

output "github_oidc_role_name" {
  description = "Name of the GitHub OIDC role for CloudTrail management"
  value       = var.enable_github_cicd_roles ? module.github_cicd_cloudtrail[0].oidc_role_name : null
}

output "github_cicd_role_arn" {
  description = "ARN of the GitHub CICD role for CloudTrail management"
  value       = var.enable_github_cicd_roles ? module.github_cicd_cloudtrail[0].cicd_role_arn : null
}

output "github_cicd_role_name" {
  description = "Name of the GitHub CICD role for CloudTrail management"
  value       = var.enable_github_cicd_roles ? module.github_cicd_cloudtrail[0].cicd_role_name : null
}

# CloudTrail outputs
output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = var.enable_cloudtrail_trail ? module.cloudtrail_trail[0].trail_arn : null
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  value       = var.enable_cloudtrail_trail ? module.cloudtrail_trail[0].trail_id : null
}

output "cloudtrail_bucket_name" {
  description = "Name of the S3 bucket storing CloudTrail logs"
  value       = var.enable_cloudtrail_bucket ? module.cloudtrail_bucket[0].bucket_name : null
}

output "cloudtrail_bucket_arn" {
  description = "ARN of the S3 bucket storing CloudTrail logs"
  value       = var.enable_cloudtrail_bucket ? module.cloudtrail_bucket[0].bucket_arn : null
}

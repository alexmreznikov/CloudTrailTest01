output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "oidc_role_arn" {
  description = "ARN of the GitHub OIDC role"
  value       = aws_iam_role.github_oidc.arn
}

output "oidc_role_name" {
  description = "Name of the GitHub OIDC role"
  value       = aws_iam_role.github_oidc.name
}

output "cicd_role_arn" {
  description = "ARN of the GitHub CICD role"
  value       = aws_iam_role.github_cicd.arn
}

output "cicd_role_name" {
  description = "Name of the GitHub CICD role"
  value       = aws_iam_role.github_cicd.name
}

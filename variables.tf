variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "ap-southeast-2"
}

variable "serviceid" {
  description = "Service ID for CMDB tracking"
  type        = string
}

variable "env_key" {
  description = "Environment key for tagging (canary, prod, etc.)"
  type        = string
}

variable "github_org" {
  description = "GitHub organization name for OIDC authentication"
  type        = string
  default     = "alexmreznikov"
}

variable "github_repo" {
  description = "GitHub repository name for CloudTrail management (without org prefix)"
  type        = string
  default     = ""
}

variable "oidc_role_name" {
  description = "Name of the GitHub OIDC role"
  type        = string
  default     = "org-mgmt-GithubOIDCRole"
}

variable "cicd_role_name" {
  description = "Name of the GitHub CICD role for CloudTrail"
  type        = string
  default     = "org-mgmt-GithubCICDRole"
}

variable "terraform_state_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform state storage"
  type        = string
}

variable "enable_github_cicd_roles" {
  description = "Enable GitHub CICD roles module"
  type        = bool
  default     = false
}

variable "enable_cloudtrail_bucket" {
  description = "Enable CloudTrail S3 bucket module"
  type        = bool
  default     = false
}

variable "enable_cloudtrail_trail" {
  description = "Enable CloudTrail trail module"
  type        = bool
  default     = false
}

variable "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
  default     = "org-mgmt-cloudtrail"
}

variable "cloudtrail_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
  default     = "org-mgmt-cloudtrail-logs"
}

variable "cloudtrail_log_retention_days" {
  description = "Number of days to retain CloudTrail logs (0 = no expiration)"
  type        = number
  default     = 90
}

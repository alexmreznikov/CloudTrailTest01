variable "oidc_role_name" {
  description = "Name of the GitHub OIDC role"
  type        = string
}

variable "cicd_role_name" {
  description = "Name of the GitHub CICD role"
  type        = string
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without org prefix)"
  type        = string
}

variable "serviceid" {
  description = "Service ID for CMDB tracking"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

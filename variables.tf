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

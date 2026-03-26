variable "bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
}

variable "serviceid" {
  description = "Service ID for CMDB tracking"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudTrail logs (0 = no expiration)"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

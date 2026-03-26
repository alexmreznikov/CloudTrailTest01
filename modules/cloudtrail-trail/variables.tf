variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket where CloudTrail logs will be stored"
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

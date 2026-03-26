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

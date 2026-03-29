# CloudTrail Trail outputs
output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = var.enable_cloudtrail_trail ? module.cloudtrail_trail[0].trail_arn : null
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  value       = var.enable_cloudtrail_trail ? module.cloudtrail_trail[0].trail_id : null
}

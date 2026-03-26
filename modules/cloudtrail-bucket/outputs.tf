output "bucket_name" {
  description = "Name of the S3 bucket storing CloudTrail logs"
  value       = aws_s3_bucket.ct_bucket.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket storing CloudTrail logs"
  value       = aws_s3_bucket.ct_bucket.arn
}

output "bucket_id" {
  description = "ID of the S3 bucket storing CloudTrail logs"
  value       = aws_s3_bucket.ct_bucket.id
}

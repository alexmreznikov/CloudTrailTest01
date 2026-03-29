# CloudTrail Trail
# This configuration creates a multi-region CloudTrail trail
# that logs to the S3 bucket managed by CloudTrailBucket01

module "cloudtrail_trail" {
  count  = var.enable_cloudtrail_trail ? 1 : 0
  source = "./modules/cloudtrail-trail"

  trail_name     = var.cloudtrail_name
  s3_bucket_name = var.s3_bucket_name
  serviceid      = var.serviceid

  tags = {
    Environment = var.env_key
    Purpose     = "Multi-region CloudTrail audit logging"
  }
}

# CloudTrail S3 Bucket
# This configuration creates an S3 bucket for storing CloudTrail logs

module "cloudtrail_bucket" {
  count  = var.enable_cloudtrail_bucket ? 1 : 0
  source = "./modules/cloudtrail-bucket"

  bucket_name        = var.cloudtrail_bucket_name
  log_retention_days = var.cloudtrail_log_retention_days
  serviceid          = var.serviceid

  tags = {
    Environment = var.env_key
    Purpose     = "CloudTrail log storage"
  }
}

# CloudTrail Trail
# This configuration creates a multi-region CloudTrail trail
# that logs to the S3 bucket created above

module "cloudtrail_trail" {
  count  = var.enable_cloudtrail_trail ? 1 : 0
  source = "./modules/cloudtrail-trail"

  trail_name     = var.cloudtrail_name
  s3_bucket_name = var.enable_cloudtrail_bucket ? module.cloudtrail_bucket[0].bucket_name : var.cloudtrail_bucket_name
  serviceid      = var.serviceid

  tags = {
    Environment = var.env_key
    Purpose     = "Multi-region CloudTrail audit logging"
  }

  depends_on = [module.cloudtrail_bucket]
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "ct_bucket" {
  bucket = var.bucket_name

  tags = merge(
    {
      "is-guardrail"                       = "true"
      "cmdb-technical-service-offering-id" = var.serviceid
      "Name"                               = var.bucket_name
    },
    var.tags
  )
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "ct_bucket_block" {
  bucket = aws_s3_bucket.ct_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning for the bucket
resource "aws_s3_bucket_versioning" "ct_bucket_versioning" {
  bucket = aws_s3_bucket.ct_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "ct_bucket_encryption" {
  bucket = aws_s3_bucket.ct_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle policy for log retention
resource "aws_s3_bucket_lifecycle_configuration" "ct_bucket_lifecycle" {
  count  = var.log_retention_days > 0 ? 1 : 0
  bucket = aws_s3_bucket.ct_bucket.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    expiration {
      days = var.log_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Bucket policy to allow CloudTrail to write logs
resource "aws_s3_bucket_policy" "ct_bucket_policy" {
  bucket = aws_s3_bucket.ct_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.ct_bucket.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.ct_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.ct_bucket_block]
}

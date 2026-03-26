# CloudTrail Bucket Module

This module creates an S3 bucket configured for CloudTrail logging.

## Features

- **S3 bucket with security best practices**:
  - Public access blocked
  - Versioning enabled
  - Server-side encryption (AES256)
  - Lifecycle policy for log retention
- **Proper IAM policies**: CloudTrail has permissions to write logs to S3

## Usage

```hcl
module "cloudtrail_bucket" {
  source = "./modules/cloudtrail-bucket"

  bucket_name         = "my-cloudtrail-logs-bucket"
  log_retention_days  = 90
  serviceid           = "CI000111111"

  tags = {
    Environment = "prod"
    Purpose     = "CloudTrail logging"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| bucket_name | Name of the S3 bucket for CloudTrail logs | string | - | yes |
| serviceid | Service ID for CMDB tracking | string | - | yes |
| log_retention_days | Number of days to retain CloudTrail logs (0 = no expiration) | number | 90 | no |
| tags | Additional tags to apply to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_name | Name of the S3 bucket storing CloudTrail logs |
| bucket_arn | ARN of the S3 bucket storing CloudTrail logs |
| bucket_id | ID of the S3 bucket storing CloudTrail logs |

## Notes

- The S3 bucket name must be globally unique across AWS
- CloudTrail requires specific bucket policies which are automatically configured
- Logs are retained for the specified number of days (default: 90 days)

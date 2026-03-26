# CloudTrail Trail Module

This module creates a multi-region AWS CloudTrail trail that logs to an existing S3 bucket.

## Features

- **Multi-region CloudTrail trail**: Captures events from all AWS regions
- **Global service events**: Includes events from global services like IAM
- **Event selectors**: Captures all management events and S3 data events
- **Automatic logging**: Trail starts logging immediately upon creation

## Usage

```hcl
module "cloudtrail_trail" {
  source = "./modules/cloudtrail-trail"

  trail_name      = "my-cloudtrail"
  s3_bucket_name  = "my-cloudtrail-logs-bucket"
  serviceid       = "CI000111111"

  tags = {
    Environment = "prod"
    Purpose     = "Audit logging"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| trail_name | Name of the CloudTrail trail | string | - | yes |
| s3_bucket_name | Name of the S3 bucket where CloudTrail logs will be stored | string | - | yes |
| serviceid | Service ID for CMDB tracking | string | - | yes |
| tags | Additional tags to apply to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| trail_arn | ARN of the CloudTrail trail |
| trail_id | Name of the CloudTrail trail |
| trail_name | Name of the CloudTrail trail |

## Notes

- The S3 bucket must exist before creating the trail
- The S3 bucket must have the proper CloudTrail bucket policy configured
- The trail captures all management events and S3 object-level API activity
- Use the `cloudtrail-bucket` module to create a properly configured bucket

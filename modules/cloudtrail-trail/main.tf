# CloudTrail trail (multi-region)
resource "aws_cloudtrail" "main" {
  name                          = var.trail_name
  s3_bucket_name                = var.s3_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = merge(
    {
      "is-guardrail"                       = "true"
      "cmdb-technical-service-offering-id" = var.serviceid
      "Name"                               = var.trail_name
    },
    var.tags
  )
}

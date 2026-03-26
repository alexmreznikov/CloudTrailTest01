provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "cmdb-technical-service-offering-id" = var.serviceid
      "ManagedBy"                          = "Terraform"
      "Environment"                        = var.env_key
    }
  }
}

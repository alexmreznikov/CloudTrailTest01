terraform {
  backend "s3" {
    bucket  = "org-mgmt-terraform-state-alexorg-local"
    key     = "cloudtrail/terraform.tfstate"
    region  = "ap-southeast-2"
    encrypt = true
  }
}

terraform {
  backend "s3" {
    bucket  = "org-mgmt-terraform-state-alexorg-local"
    key     = "terraform.tfstate"
    region  = "ap-southeast-2"
    encrypt = true
  }
}

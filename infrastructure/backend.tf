terraform {
  backend "s3" {
    bucket = "ddc-terraform-backend-state"
    key    = "ddc/terraform/backend/state"
    region = "us-east-1"
  }
}
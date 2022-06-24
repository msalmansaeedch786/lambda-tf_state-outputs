variable "aws_region" {
  type        = string
  description = "default region for the aws account"
}

variable "arbitrary_terraform_state_files_bucket" {
  type        = string
  description = "bucket name for arbitrary terraform state files"
}
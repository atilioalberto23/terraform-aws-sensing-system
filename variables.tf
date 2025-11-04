# variables.tf
variable "lambda_code_bucket" {
  description = "S3 bucket to store Lambda code"
  type        = string
}

variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

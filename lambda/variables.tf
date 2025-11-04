# variables.tf
variable "lambda_code_bucket" {
  description = "S3 bucket to store Lambda code"
  type        = string
}

variable "table_arn" {
  description = "ARN de la tabla DynamoDB"
  type        = string
}

variable "table_name" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
}


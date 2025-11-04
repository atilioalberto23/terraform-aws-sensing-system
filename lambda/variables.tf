# variables.tf
variable "nombre_lambda_rol" {
  description = "Nombre literal del nombre del rol para la lambda"
  type        = string
}

variable "nombre_funcion_lambda" {
  description = "Nombre literal de la función lambda"
  type        = string
}

variable "lambda_code_bucket" {
  description = "S3 bucket to store Lambda code"
  type        = string
}

variable "lambda_code_key" {
  description = "S3 key to store Lambda code"
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


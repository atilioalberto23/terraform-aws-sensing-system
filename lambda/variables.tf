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


###//////////////// REPLICACIÓN A S3 DYNAMODB //////////////////###

variable "lambda_dynamodb_replica_key" {
  description = "S3 key to store Lambda code"
  type        = string
}

variable "bucket_raw_parquet" {
  description = "Bucket que contiene la data raw en formato parquet"
  type        = string
}

variable "nombre_lambda_rol_replicacion" {
  description = "Nombre literal del nombre del rol para la lambda de replicacion"
  type        = string
}

variable "nombre_funcion_lambda_replicacion" {
  description = "Nombre literal de la función para la lambda de replicacion"
  type        = string
}

variable "dynamodb_stream_arn" {
  type        = string
  description = "ARN del DynamoDB Stream que Lambda usará"
}
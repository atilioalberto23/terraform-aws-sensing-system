# variables.tf
variable "nombre_lambda_rol" {
  description = "S3 bucket to store Lambda code"
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
  description = "S3 bucket to store Lambda code"
  type        = string
}

variable "nombre_api" {
  description = "Nombre literal de la API"
  type        = string
}


variable "nombre_tabla_dynamo" {
  description = "Nombre literal de la tabla DynamoDB"
  type        = string
}


variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}



###//////////////// REPLICACIÓN A S3 DYNAMODB //////////////////###

variable "lambda_dynamodb_replica_key" {
  description = "S3 bucket to store Lambda code"
  type        = string
}

variable "bucket_raw_parquet_data" {
  description = "Nombre literal del bucket donde se replicará la data en formato parquet"
  type        = string
}


variable "nombre_lambda_rol_replicacion" {
  description = "Nombre literal del rol de la lambda de replicacion"
  type        = string
}

variable "nombre_funcion_lambda_replicacion" {
  description = "Nombre literal de la lambda de replicacion"
  type        = string
}


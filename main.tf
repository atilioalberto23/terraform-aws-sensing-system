

# main.tf
provider "aws" {
  region = "us-east-1" # Cambia según tu región
}


# Referencia a las variables
module "lambda" {
  source = "./lambda"
  nombre_lambda_rol = var.nombre_lambda_rol
  nombre_funcion_lambda = var.nombre_funcion_lambda
  lambda_code_bucket = var.lambda_code_bucket
  lambda_code_key = var.lambda_code_key
  lambda_dynamodb_replica_key = var.lambda_dynamodb_replica_key
  table_arn   = module.dynamodb.table_arn
  table_name  = module.dynamodb.table_name
  bucket_raw_parquet = module.s3_bucket.bucket_raw_parquet
  nombre_lambda_rol_replicacion = var.nombre_lambda_rol_replicacion
  nombre_funcion_lambda_replicacion = var.nombre_funcion_lambda_replicacion
}

module "api_gateway" {
  source              = "./api_gateway"
  nombre_api = var.nombre_api
  lambda_function_arn = module.lambda.lambda_function_arn
  lambda_function_name = module.lambda.lambda_function_name
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
}



module "dynamodb" {
  source = "./dynamodb"
  nombre_tabla_dynamo = var.nombre_tabla_dynamo
  lambda_replication_name  = module.lambda.lambda_replication_name
}

module "s3_bucket" {
  source = "./s3_bucket"
  bucket_raw_parquet_data = var.bucket_raw_parquet_data

}






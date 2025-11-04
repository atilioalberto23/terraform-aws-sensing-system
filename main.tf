

# main.tf
provider "aws" {
  region = "us-east-1" # Cambia según tu región
}


# Referencia a las variables
module "lambda" {
  source = "./lambda"
  lambda_code_bucket = "terraform-pruebas-lambda"
  table_arn   = module.dynamodb.table_arn
  table_name  = module.dynamodb.table_name
}

module "api_gateway" {
  source              = "./api_gateway"
  lambda_function_arn = module.lambda.lambda_function_arn
  lambda_function_name = module.lambda.lambda_function_name
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
}

module "dynamodb" {
  source = "./dynamodb"
}





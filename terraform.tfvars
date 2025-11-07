# terraform.tfvars
lambda_code_bucket = "terraform-pruebas-lambda"
lambda_code_key = "codigo-lambda"
nombre_api = "esp32-endpoint-lambda"
nombre_tabla_dynamo = "esp32-sensing-system-table"
nombre_lambda_rol = "lambda-dynamo-rol"
nombre_funcion_lambda = "api-dynamodb-lambdaFx"


###//////////////// REPLICACIÓN A S3 DYNAMODB //////////////////###
lambda_dynamodb_replica_key = "codigo-lambda-dynamodb-streams"
bucket_raw_parquet_data = "raw_00"






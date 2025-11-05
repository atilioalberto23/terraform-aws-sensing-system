


# api_gateway.tf

#Se define el nombre de la API que recibirá el POST desde la ESP32
resource "aws_api_gateway_rest_api" "esp32_api" {
  name        = var.nombre_api
  description = "API para recibir datos desde ESP32"
}

#Se define el recurso de la API Gateway
resource "aws_api_gateway_resource" "esp32_resource" {
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  parent_id   = aws_api_gateway_rest_api.esp32_api.root_resource_id
  path_part   = "data"
}

#Se define el metodo POST de la API Gateway
resource "aws_api_gateway_method" "esp32_method" {
  rest_api_id   = aws_api_gateway_rest_api.esp32_api.id
  resource_id   = aws_api_gateway_resource.esp32_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

#Se define la integracion lambda de la API Gateway
resource "aws_api_gateway_integration" "esp32_integration" {
  rest_api_id             = aws_api_gateway_rest_api.esp32_api.id
  resource_id             = aws_api_gateway_resource.esp32_resource.id
  http_method             = aws_api_gateway_method.esp32_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${var.lambda_invoke_arn}/invocations"
}



# Permitir que API Gateway invoque Lambda
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.esp32_api.execution_arn}/*/*"
}

#Deployment de la API Gateway
resource "aws_api_gateway_deployment" "esp32_deployment" {
  depends_on = [aws_api_gateway_integration.esp32_integration]
  rest_api_id = aws_api_gateway_rest_api.esp32_api.id
  description = "Deployment automático de la API ESP32"
}

#Staget productivo
resource "aws_api_gateway_stage" "esp32_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.esp32_api.id
  deployment_id = aws_api_gateway_deployment.esp32_deployment.id
}

# Exportación del recurso del módulo
output "api_gateway_url" {
  value = aws_api_gateway_rest_api.esp32_api.execution_arn
  description = "The URL of the API Gateway"
}

output "api_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.esp32_api.id}.execute-api.us-east-1.amazonaws.com/prod/esp32"
  description = "Invoke URL for the ESP32 API"
}


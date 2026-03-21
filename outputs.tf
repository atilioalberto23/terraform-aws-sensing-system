output "api_gateway_url" {
  value = module.api_gateway.api_gateway_url
  description = "Invoke URL for the ESP32 API"
}

output "api_gateway_invoke" {
  value = module.api_gateway.api_invoke_url
  description = "Invoke URL for ESP32 API Gateway endpoint"
}

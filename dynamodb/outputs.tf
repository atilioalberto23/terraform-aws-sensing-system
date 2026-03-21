output "table_arn" {
  description = "ARN de la tabla DynamoDB creada"
  value       = aws_dynamodb_table.esp32_data.arn
}

output "table_name" {
  description = "Nombre de la tabla DynamoDB"
  value       = aws_dynamodb_table.esp32_data.name
}

output "esp32_data_stream_arn" {
  value = aws_dynamodb_table.esp32_data.stream_arn
}
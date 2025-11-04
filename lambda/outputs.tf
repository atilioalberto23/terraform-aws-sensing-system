output "lambda_function_arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.lambda_function.function_name
}

output "lambda_invoke_arn" {
  description = "Invoke ARN de la función Lambda"
  value       = aws_lambda_function.lambda_function.arn
}

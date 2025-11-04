variable "nombre_api" {
  description = "Nombre literal de la API"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN de la función Lambda existente"
  type        = string
}

variable "lambda_function_name" {
  description = "Nombre de la función Lambda existente"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN de la función Lambda"
  type        = string
}


provider "aws" {
  region = "us-east-1"  # Región donde está tu bucket
}


# lambda.tf
resource "aws_iam_role" "lambda_role" {
  name = var.nombre_lambda_rol

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda-s3-policy"
  description = "Permite acceso a S3 para la Lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.lambda_code_bucket}/*"
      }
    ]
  })

}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda-dynamodb-policy"
  description = "Permite a Lambda escribir en la tabla DynamoDB creada por Terraform"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Effect = "Allow"
        Resource = "*"
        #Resource = var.table_arn
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_attach_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_attach_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}


resource "aws_lambda_function" "lambda_function" {
  function_name = var.nombre_funcion_lambda
  role          = aws_iam_role.lambda_role.arn
  handler       = "${var.lambda_code_key}.lambda_handler"
  runtime       = "python3.10"

  # Cargar código Lambda desde un bucket S3
  s3_bucket = var.lambda_code_bucket
  s3_key    = "${var.lambda_code_key}.zip"
}



provider "aws" {
  region = "us-east-1"  # Región donde está tu bucket
}


# lambda.tf

#Se crea el rol para la lambda. La misma (lambda) debe ser capaz de asumir el rol.
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

#Policy que le permite a la lambda accesar al bucket de S3 que contiene el código
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

#Se crea la politica para que la lambda pueda acceder a la tabla DynamoDB
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

#Se anexa la policy que permite el acceso a S3, a la lambda, al rol creado para la lambda.
resource "aws_iam_role_policy_attachment" "lambda_attach_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}


#Se anexa la policy que permite el acceso a DynamoDB, a la lambda, al rol creado para la lambda.
resource "aws_iam_role_policy_attachment" "lambda_attach_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

#Se crea la funcion lambda y se le adjunta el rol que da acceso a S3, DynamoDB y le permite asumir el rol.
resource "aws_lambda_function" "lambda_function" {
  function_name = var.nombre_funcion_lambda
  role          = aws_iam_role.lambda_role.arn
  handler       = "${var.lambda_code_key}.lambda_handler"
  runtime       = "python3.10"

  # Cargar código Lambda desde un bucket S3
  s3_bucket = var.lambda_code_bucket
  s3_key    = "${var.lambda_code_key}.zip"

  environment {
    variables = {
      DYNAMODB_TABLE = var.table_name
    }
  }
}



###//////////////// REPLICACIÓN A S3 DYNAMODB //////////////////###



#CONTINUAR...


#Se crea el rol para la lambda. La misma (lambda) debe ser capaz de asumir el rol.
resource "aws_iam_role" "lambda_role_replication" {
  name = var.nombre_lambda_rol_replicacion

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

#Policy que le permite a la lambda accesar al bucket de S3 que contiene el código
resource "aws_iam_policy" "lambda_s3_policy_replicacion" {
  name        = "lambda-s3-policy-replicacion"
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
      },
      {
        Action   = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.bucket_raw_parquet}/*"
      }
    ]
  })
}


#Se crea la politica para que la lambda pueda acceder a la tabla DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_policy_replicacion" {
  name        = "lambda-dynamodb-policy-replicacion"
  description = "Permite a Lambda leer la tabla DynamoDB creada por Terraform"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem"
        ]
        Effect = "Allow"
        Resource = "*"
        #Resource = var.table_arn
      }
    ]
  })
}


resource "aws_iam_policy" "lambda_dynamodb_stream_policy" {
  name        = "lambda-dynamodb-stream-policy"
  description = "Permite acceso a los streams de DynamoDB desde Lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:ListStreams"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:us-east-1:417414404705:table/${var.table_name}/stream/*"
      }
    ]
  })
}





#Se anexa la policy que permite el acceso a S3, a la lambda, al rol creado para la lambda.
resource "aws_iam_role_policy_attachment" "lambda_attach_s3_replicacion" {
  role       = aws_iam_role.lambda_role_replication.name
  policy_arn = aws_iam_policy.lambda_s3_policy_replicacion.arn
}


#Se anexa la policy que permite el acceso a DynamoDB, a la lambda, al rol creado para la lambda.
resource "aws_iam_role_policy_attachment" "lambda_attach_dynamodb_s3_replicacion" {
  role       = aws_iam_role.lambda_role_replication.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy_replicacion.arn
}

resource "aws_iam_role_policy_attachment" "lambda_attach_dynamodb_stream_policy" {
  role       = aws_iam_role.lambda_role_replication.name
  policy_arn = aws_iam_policy.lambda_dynamodb_stream_policy.arn
}


















resource "aws_lambda_function" "save_to_s3" {
  function_name    = var.nombre_funcion_lambda_replicacion
  role             = aws_iam_role.lambda_role_replication.arn
  handler          = "${var.lambda_dynamodb_replica_key}.lambda_handler"  # Nombre de la función manejadora en Python
  runtime          = "python3.10"

  s3_bucket = var.lambda_code_bucket
  s3_key = "${var.lambda_dynamodb_replica_key}.zip"

  environment {
    variables = {
      BUCKET_NAME = var.bucket_raw_parquet  # El bucket de S3 donde guardamos los datos Parquet
    }
  }
}











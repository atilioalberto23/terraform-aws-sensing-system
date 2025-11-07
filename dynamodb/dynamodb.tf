# dynamodb.tf

#Creacion de la tabla DynamoDB; Se tiene una llave compuesta: nodo_id (PK) y request_time (SK) para no sobre-escribir la lectura.
resource "aws_dynamodb_table" "esp32_data" {
  name           = var.nombre_tabla_dynamo
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "nodo_id"    # Partition key
  range_key      = "request_time" # Sorting key

  #Se define el tipo de dato de la partition key
  attribute {
    name = "nodo_id"  # Define la partition key
    type = "S"        # Tipo de dato para nodo_id (String)
  }

  #Se define el tipo de dato de la sorting key
  attribute {
    name = "request_time" # Define la sorting key
    type = "S"            # Tipo de dato para request_time (String)
  }



###//////////////// REPLICACIÓN A S3 DYNAMODB //////////////////###

  # DynamoDB Stream habilitado para capturar eventos
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"  # Solo captura los nuevos registros insertados

  # TTL configurado para 8 horas de retención de datos
  ttl {
    attribute_name = "expirationTime"
    enabled        = true
  }

  tags = {
    Name = "esp32_data_dynamodb_table"
  }


}





resource "aws_lambda_event_source_mapping" "dynamo_stream_trigger" {
  event_source_arn  = aws_dynamodb_table.esp32_data.stream_arn
  function_name     = var.lambda_replication_name
  starting_position = "LATEST"  # Procesar desde el último evento en el stream

  # Opcional: configuramos el batch size para procesar múltiples registros a la vez
  batch_size        = 100
}






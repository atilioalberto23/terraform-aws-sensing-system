# dynamodb.tf
resource "aws_dynamodb_table" "esp32_data" {
  name           = var.nombre_tabla_dynamo
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "nodo_id"    # Partition key
  range_key      = "request_time" # Sorting key

  attribute {
    name = "nodo_id"  # Define la partition key
    type = "S"        # Tipo de dato para nodo_id (String)
  }

  attribute {
    name = "request_time" # Define la sorting key
    type = "S"            # Tipo de dato para request_time (String)
  }

}

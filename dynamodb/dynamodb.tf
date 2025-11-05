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

}

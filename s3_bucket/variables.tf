###//////////////// REPLICACIÓN A S3 DYNAMODB //////////////////###

variable "bucket_raw_parquet_data" {
  description = "Nombre literal del bucket donde se replicará la data en formato parquet"
  type        = string
}
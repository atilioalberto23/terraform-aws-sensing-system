output "bucket_raw_parquet" {
  description = "Nombre de la tabla DynamoDB"
  value       = aws_s3_bucket.iot_data_parquet.bucket
}



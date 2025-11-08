provider "aws" {
  region = "us-east-1"  # Región donde está tu bucket
}

resource "aws_s3_bucket" "iot_data_parquet" {
  bucket = var.bucket_raw_parquet_data

  tags = {
    Name = "iot-data-parquet"
  }
}
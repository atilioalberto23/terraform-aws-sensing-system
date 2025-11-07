

resource "aws_s3_bucket" "iot_data_parquet" {
  bucket = var.bucket_raw_parquet_data

  tags = {
    Name = "iot-data-parquet"
  }
}
import json
import boto3
import time
import os
import uuid
import pyarrow as pa
import pyarrow.parquet as pq

# Cliente de S3 para interactuar con el bucket
s3 = boto3.client('s3_bucket')
bucket = os.environ['BUCKET_NAME']  # El nombre del bucket se pasa como variable de entorno

def lambda_handler(event, context):
    timestamp = int(time.time())
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            # Extraer el nuevo ítem desde DynamoDB Stream
            new_item = record['dynamodb']['NewImage']
            data = {k: list(v.values())[0] for k, v in new_item.items()}

            # Generar un ID único para este registro, usando UUID basado en el payload (para asegurar unicidad)
            unique_id = str(data['payload']['msr_prd_id'])  # Usamos el 'payload' para generar un UUID

            # Crear el nombre del archivo para S3: "nodo_id/unique_id.parquet"
            file_name = f"data/{data['nodo_id']}/{unique_id}.parquet"

            # Convertir los datos a formato Parquet usando PyArrow
            table = pa.table(data)  # Usamos PyArrow para crear la tabla

            # Guardamos los datos en un archivo Parquet temporal
            with open("/tmp/temp.parquet", "wb") as f:
                pq.write_table(table, f)

            # Subimos el archivo Parquet a S3 en la ruta especificada
            s3.upload_file("/tmp/temp.parquet", bucket, file_name)

    return {'statusCode': 200}

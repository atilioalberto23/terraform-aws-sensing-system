import json
import boto3
import time
import os
import uuid

# Cliente de S3 para interactuar con el bucket
s3 = boto3.client('s3')
bucket = os.environ['BUCKET_NAME']  # El nombre del bucket se pasa como variable de entorno


def lambda_handler(event, context):
    try:
        # Verificar que el evento contiene la clave 'Records'
        if 'Records' not in event:
            raise ValueError("El evento no contiene la clave 'Records'")

        timestamp = int(time.time())  # Timestamp para diferenciar las escrituras

        for record in event['Records']:
            if record['eventName'] == 'INSERT':  # Solo procesamos los eventos de inserción
                # Extraer el nuevo ítem desde DynamoDB Stream
                new_item = record['dynamodb']['NewImage']
                data = {k: list(v.values())[0] for k, v in new_item.items()}

                # Generar un ID único para este registro usando 'nodo_id' y 'msr_prd_id' del payload
                unique_id = f"{data['nodo_id']}_{data['payload']['msr_prd_id']}_{timestamp}"  # ID único con timestamp
                print(f"Generando archivo para: {unique_id}")

                # Crear el nombre del archivo para S3: "nodo_id/unique_id.json"
                file_name = f"data/{data['nodo_id']}/{unique_id}.json"

                # Convertir los datos en un formato JSON (DynamoDB devuelve los datos como JSON)
                json_data = json.dumps(data)

                # Subir el archivo JSON a S3 en la ruta especificada
                s3.put_object(Bucket=bucket, Key=file_name, Body=json_data)

                print(f"Archivo guardado en S3: {file_name}")

        return {'statusCode': 200, 'body': 'Success'}

    except Exception as e:
        print(f"Error: {str(e)}")
        return {'statusCode': 500, 'body': f"Error: {str(e)}"}

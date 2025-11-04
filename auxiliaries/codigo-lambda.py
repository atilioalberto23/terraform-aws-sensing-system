import os
import json
import boto3
from decimal import Decimal
from datetime import datetime, timezone

# Inicializar recursos
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('TABLE_NAME', 'esp32-data-table_terraform')
table = dynamodb.Table(TABLE_NAME)

def iso_utc_now():
    return datetime.now(timezone.utc).isoformat(timespec='milliseconds')

def lambda_handler(event, context):
    try:
        # API Gateway HTTP API v2: body viene como string en event['body']
        body_raw = event.get('body', '{}')
        # Convertir floats a Decimal automáticamente
        data = json.loads(body_raw, parse_float=Decimal)

        # Validaciones mínimas
        sensor_id = data.get('sensor_id')
        request_time = data.get('request_time')  # esperamos ISO8601 string
        if not sensor_id or not request_time:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'sensor_id and request_time are required'})
            }

        # arrival_time: momento exacto en que Lambda procesa la petición
        arrival_time = iso_utc_now()

        # Construir item
        item = {
            'nodo_id': sensor_id,
            'request_time': request_time,
            'arrival_time': arrival_time,
            # Guardamos el payload completo (puede contener temp, hum, etc)
            'payload': data.get('payload', data)  # si el cliente envía payload o envía campos planos
        }

        # Si payload contiene floats, ya fueron convertidos a Decimal por parse_float
        # Es seguro llamar a put_item
        table.put_item(Item=item)

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'ok', 'sensor_id': sensor_id, 'request_time': request_time, 'arrival_time': arrival_time})
        }

    except Exception as e:
        # Log automático en CloudWatch
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

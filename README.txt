Remove-Item -Recurse -Force .terraform, .terraform.lock.hcl, terraform.tfstate, terraform.tfstate.backup


0.1 Crear usuario en S3 para acceder mediante terraform
0.2 Crear bucket con objeto lambda.py

0. Introducir credenciales AWS:
    - $env:AWS_ACCESS_KEY_ID=""
    - $env:AWS_SECRET_ACCESS_KEY=""
    - $env:AWS_REGION="us-east-1"

1. Ejecutar "terraform init"
2. Ejecutar "terraform plan"
3. Ejecutar "terraform apply"

Nota: La url para la invocación de la API, mediante un HTTP request desde la ESP32, estará dada como un output:
"api_gateway_url"

Para destruir la infraestructura:
1. Hacer, si no se ha hecho: "terraform init"
2. Ejecutar "terraform plan -destroy"
3. Ejecutar "terraform destroy"
4. Remove-Item -Recurse -Force .terraform, .terraform.lock.hcl, terraform.tfstate, terraform.tfstate.backup

SIEMPRE DESTRUIR LA INFRAESTRUCTURA ANTES DE ENVIAR UN COMMIT A DEVELOP Y REMOVER ARHCHIVOS .tfstate y .backup


RECORDAR:

1. Actualizar código de la lambda.py para que coincida con el nombre de la tabla dynamo.
2. Actualizar código de la esp32.c para que coincida con el http url de la api.


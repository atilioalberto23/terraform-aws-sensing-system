Remove-Item -Recurse -Force .terraform, .terraform.lock.hcl, terraform.tfstate, terraform.tfstate.backup


CUIDADO esp32-data-table_terraform -

0. Introducir credenciales AWS:
    - $env:AWS_ACCESS_KEY_ID = "AKIAWCL6WLJQQKNGIIXG"
    - $env:AWS_SECRET_ACCESS_KEY = "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"
    - $env:AWS_REGION = "us-east-1"

1. Ejecutar "terraform init"
2. Ejecutar "terraform plan"
3. Ejecutar "teraform apply"

Nota: La url para la invocación de la API, mediante un HTTP request desde la ESP32, estará dada como un output:
"api_gateway_url"

Para destruir la infraestructura:
1. Hacer, si no se ha hecho: "terraform init"
2. Ejecutar "terraform plan -destroy"
3. Ejecutar "terraform destroy"

SIEMPRE DESTRUIR LA INFRAESTRUCTURA ANTES DE ENVIAR UN COMMIT A DEVELOP Y REMOVER ARHCHIVOS .tfstate y .backup
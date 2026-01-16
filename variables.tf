# Variables de configuración para el proyecto Terraform
# Estas variables parametrizan la infraestructura para facilitar cambios y reutilización

variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura. us-east-1 (Virginia) es económica y tiene todos los servicios."
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Nombre de la función Lambda. Debe ser único en tu cuenta AWS para la región especificada."
  type        = string
  default     = "fastlabs-hello-lambda"
}

variable "lambda_runtime" {
  description = "Runtime de Lambda. nodejs20.x es la versión más reciente soportada con features modernas de JavaScript."
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_timeout" {
  description = "Timeout en segundos para la ejecución de Lambda. Valores más altos incrementan el costo potencial si la función se cuelga."
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Memoria en MB asignada a Lambda. Más memoria = más CPU proporcionalmente. Mínimo 128 MB, máximo 10240 MB."
  type        = number
  default     = 128
}

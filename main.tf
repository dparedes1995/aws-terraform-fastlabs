# Configuración principal de Terraform para AWS Lambda + CloudWatch Logs

# Provider AWS - maneja autenticación y conexión con AWS
# Usa credenciales de .env (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
provider "aws" {
  region = var.aws_region
}

# Random ID para crear sufijos únicos en nombres de IAM roles
# Previene conflictos cuando destruyes y recreas recursos durante desarrollo
# El keeper garantiza que se regenere solo si cambia el nombre de la función
resource "random_id" "suffix" {
  byte_length = 4
  keepers = {
    function_name = var.lambda_function_name
  }
}

# Data source para Trust Policy - define QUIÉN puede asumir el role
# Lambda necesita permiso para "asumir" (AssumeRole) el IAM role que le das
# Esto es diferente a los permisos que el role tiene (resource policies)
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM Role para Lambda - identidad que la función asume durante ejecución
# Nombre incluye random suffix para evitar conflictos en desarrollo iterativo
# Tags permiten organización y cost tracking en AWS Cost Explorer
resource "aws_iam_role" "lambda_role" {
  name               = "${var.lambda_function_name}-role-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Environment = "learning"
    Project     = "fastlabs"
  }
}

# Policy Attachment - vincula permisos al role
# AWSLambdaBasicExecutionRole es una managed policy de AWS que incluye:
# - logs:CreateLogGroup - crear log group en CloudWatch
# - logs:CreateLogStream - crear log streams dentro del group
# - logs:PutLogEvents - escribir logs (console.log)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Función Lambda - recurso principal
# filename apunta al ZIP creado por build.sh
# source_code_hash usa SHA256 del archivo para detectar cambios en código
# Terraform re-desplegará automáticamente si el hash cambia
resource "aws_lambda_function" "main" {
  filename         = "lambda.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("lambda.zip")
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  # Tags consistentes con el IAM role para tracking
  tags = {
    Environment = "learning"
    Project     = "fastlabs"
  }
}

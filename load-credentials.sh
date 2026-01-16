#!/bin/bash

# Script helper para cargar credenciales AWS desde .env
# Uso: source ./load-credentials.sh

if [ ! -f .env ]; then
  echo "❌ Error: Archivo .env no encontrado"
  exit 1
fi

# Cargar variables de entorno desde .env
source .env

# Verificar que las variables estén cargadas
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "❌ Error: Variables AWS no cargadas correctamente"
  exit 1
fi

echo "✅ Credenciales AWS cargadas exitosamente"
echo "📍 Región: $AWS_DEFAULT_REGION"
echo ""
echo "Verificando identidad..."
aws sts get-caller-identity

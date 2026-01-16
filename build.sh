#!/bin/bash

# Script de empaquetado para AWS Lambda
# Valida credenciales y crea lambda.zip con el código de la función

# Validación de .env - verifica que exista y tenga las variables necesarias
if [ ! -f .env ]; then
  echo "❌ Error: Archivo .env no encontrado"
  echo "💡 Crea un archivo .env con tus credenciales AWS (ver .env.example)"
  exit 1
fi

# Cargar .env para validar variables
source .env

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "❌ Error: Variables AWS_ACCESS_KEY_ID o AWS_SECRET_ACCESS_KEY no definidas en .env"
  exit 1
fi

echo "✅ Credenciales validadas"

# Eliminar ZIP previo si existe
if [ -f lambda.zip ]; then
  rm lambda.zip
  echo "🗑️  ZIP anterior eliminado"
fi

# Crear nuevo ZIP solo con index.js
zip -j lambda.zip index.js

# Mostrar confirmación con tamaño
if [ -f lambda.zip ]; then
  SIZE=$(ls -lh lambda.zip | awk '{print $5}')
  echo "✅ lambda.zip creado exitosamente (Tamaño: $SIZE)"
else
  echo "❌ Error al crear lambda.zip"
  exit 1
fi

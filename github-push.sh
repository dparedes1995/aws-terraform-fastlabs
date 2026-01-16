#!/bin/bash

# Script helper para subir el repositorio a GitHub
# Uso: ./github-push.sh [tu-username-de-github]

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 GitHub Push Helper - AWS Terraform FastLabs${NC}"
echo ""

# Verificar que estemos en el directorio correcto
if [ ! -f "main.tf" ] || [ ! -f "README.md" ]; then
  echo -e "${RED}❌ Error: Ejecuta este script desde la raíz del proyecto${NC}"
  exit 1
fi

# Verificar que git esté inicializado
if [ ! -d ".git" ]; then
  echo -e "${RED}❌ Error: Git no está inicializado${NC}"
  exit 1
fi

# Obtener username de GitHub
GITHUB_USERNAME=${1:-}
if [ -z "$GITHUB_USERNAME" ]; then
  echo -e "${YELLOW}📝 Ingresa tu username de GitHub:${NC}"
  read -r GITHUB_USERNAME
fi

if [ -z "$GITHUB_USERNAME" ]; then
  echo -e "${RED}❌ Error: Username de GitHub es requerido${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ Username de GitHub: $GITHUB_USERNAME${NC}"
echo ""

# Verificar archivos sensibles
echo -e "${BLUE}🔍 Verificando archivos sensibles...${NC}"

if [ -f ".env" ]; then
  if git check-ignore .env > /dev/null 2>&1; then
    echo -e "${GREEN}✅ .env está ignorado correctamente${NC}"
  else
    echo -e "${RED}❌ ERROR: .env no está en .gitignore${NC}"
    exit 1
  fi
fi

if ls *.tfstate 2>/dev/null | grep -q .; then
  echo -e "${RED}❌ ERROR: Archivos .tfstate encontrados (no deben estar versionados)${NC}"
  exit 1
else
  echo -e "${GREEN}✅ No hay archivos .tfstate${NC}"
fi

# Verificar que Terraform esté validado
echo ""
echo -e "${BLUE}🔍 Validando Terraform...${NC}"
if ! terraform fmt -check -recursive > /dev/null 2>&1; then
  echo -e "${YELLOW}⚠️  Formateando código Terraform...${NC}"
  terraform fmt -recursive
fi

if ! terraform validate > /dev/null 2>&1; then
  echo -e "${RED}❌ ERROR: Terraform validation falló${NC}"
  terraform validate
  exit 1
fi
echo -e "${GREEN}✅ Terraform validado correctamente${NC}"

# Ver archivos a commitear
echo ""
echo -e "${BLUE}📋 Archivos a subir:${NC}"
git status --short

# Confirmación
echo ""
echo -e "${YELLOW}¿Deseas continuar con el push a GitHub? (y/n):${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo -e "${RED}❌ Push cancelado${NC}"
  exit 0
fi

# Commit si hay cambios
if ! git diff-index --quiet HEAD --; then
  echo ""
  echo -e "${BLUE}📝 Creando commit...${NC}"
  git add -A
  git commit -m "feat: initial release - AWS Lambda + Terraform + CloudWatch Logs

- Add Lambda function with structured JSON logging
- Add Terraform infrastructure (IAM role + Lambda)
- Add comprehensive documentation (README, ARCHITECTURE, CONTRIBUTING)
- Add GitHub Actions for Terraform validation
- Add build and credential helper scripts
- Add LICENSE (MIT)
- Add CHANGELOG v1.0.0"
  echo -e "${GREEN}✅ Commit creado${NC}"
else
  echo -e "${GREEN}✅ No hay cambios para commitear${NC}"
fi

# Verificar si el remote ya existe
if git remote get-url origin > /dev/null 2>&1; then
  EXISTING_REMOTE=$(git remote get-url origin)
  echo ""
  echo -e "${YELLOW}⚠️  Remote 'origin' ya existe: $EXISTING_REMOTE${NC}"
  echo -e "${YELLOW}¿Deseas reemplazarlo? (y/n):${NC}"
  read -r REPLACE

  if [ "$REPLACE" == "y" ] || [ "$REPLACE" == "Y" ]; then
    git remote remove origin
    echo -e "${GREEN}✅ Remote removido${NC}"
  else
    echo -e "${BLUE}Usando remote existente${NC}"
  fi
fi

# Agregar remote si no existe
if ! git remote get-url origin > /dev/null 2>&1; then
  REPO_URL="https://github.com/$GITHUB_USERNAME/aws-terraform-fastlabs.git"
  echo ""
  echo -e "${BLUE}🔗 Agregando remote: $REPO_URL${NC}"
  git remote add origin "$REPO_URL"
  echo -e "${GREEN}✅ Remote agregado${NC}"
fi

# Cambiar a rama main si estamos en master
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo ""
  echo -e "${BLUE}🔄 Cambiando de $CURRENT_BRANCH a main...${NC}"
  git branch -M main
  echo -e "${GREEN}✅ Rama renombrada a main${NC}"
fi

# Push al repositorio
echo ""
echo -e "${BLUE}⬆️  Haciendo push a GitHub...${NC}"
if git push -u origin main; then
  echo -e "${GREEN}✅ Push exitoso!${NC}"
else
  echo -e "${RED}❌ ERROR: Push falló${NC}"
  echo ""
  echo -e "${YELLOW}Posibles causas:${NC}"
  echo -e "  1. El repositorio no existe en GitHub (créalo primero)"
  echo -e "  2. No tienes permisos de escritura"
  echo -e "  3. Necesitas autenticación (configura GitHub CLI o SSH)"
  echo ""
  echo -e "${BLUE}Comandos útiles:${NC}"
  echo -e "  gh auth login                    # Autenticar con GitHub CLI"
  echo -e "  git remote set-url origin git@github.com:$GITHUB_USERNAME/aws-terraform-fastlabs.git  # Usar SSH"
  exit 1
fi

# Crear y push tag v1.0.0
echo ""
echo -e "${BLUE}🏷️  Creando tag v1.0.0...${NC}"
if git tag -a v1.0.0 -m "Release v1.0.0 - Initial release"; then
  echo -e "${GREEN}✅ Tag creado${NC}"

  if git push origin v1.0.0; then
    echo -e "${GREEN}✅ Tag pusheado${NC}"
  else
    echo -e "${YELLOW}⚠️  No se pudo pushear el tag (puede que ya exista)${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  No se pudo crear el tag (puede que ya exista)${NC}"
fi

# Resumen final
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 ¡Repositorio subido exitosamente a GitHub!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📍 Tu repositorio:${NC}"
echo -e "   https://github.com/$GITHUB_USERNAME/aws-terraform-fastlabs"
echo ""
echo -e "${BLUE}📋 Próximos pasos recomendados:${NC}"
echo ""
echo -e "  1. ${YELLOW}Configurar Topics en GitHub:${NC}"
echo -e "     Settings → Topics → Agregar:"
echo -e "     terraform, aws-lambda, infrastructure-as-code, serverless, cloudwatch"
echo ""
echo -e "  2. ${YELLOW}Crear Release v1.0.0:${NC}"
echo -e "     Releases → Create new release → Choose tag: v1.0.0"
echo ""
echo -e "  3. ${YELLOW}Habilitar GitHub Actions:${NC}"
echo -e "     Actions → I understand my workflows → Enable"
echo ""
echo -e "  4. ${YELLOW}Compartir tu proyecto:${NC}"
echo -e "     - LinkedIn: Comparte tu aprendizaje"
echo -e "     - Twitter: Usa hashtags #Terraform #AWS #DevOps"
echo -e "     - Dev.to: Escribe un tutorial"
echo ""
echo -e "${GREEN}✨ ¡Felicidades! Tu proyecto está en GitHub${NC}"
echo ""

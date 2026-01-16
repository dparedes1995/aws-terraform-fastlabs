# AWS Lambda + Terraform + CloudWatch Logs - FastLabs

Proyecto educativo para aprender los fundamentos de infraestructura como código (IaC) con Terraform, desplegando una función AWS Lambda que escribe logs estructurados en CloudWatch.

## 🎯 ¿Qué hace este proyecto?

Despliega una función Lambda en AWS (us-east-1) que:
- Responde con statusCode 200 y body "ok"
- Escribe logs estructurados en formato JSON a CloudWatch
- Usa IAM roles con permisos mínimos (principio de least privilege)
- Soporta invocación síncrona (RequestResponse) y asíncrona (Event)

**Arquitectura:**
```
┌─────────────┐      ┌──────────────┐      ┌────────────────────┐
│  AWS CLI    │─────▶│    Lambda    │─────▶│  CloudWatch Logs   │
│  (invoke)   │      │  (Node.js)   │      │  (JSON logs)       │
└─────────────┘      └──────────────┘      └────────────────────┘
                            │
                            ▼
                     ┌──────────────┐
                     │  IAM Role    │
                     │  (permisos)  │
                     └──────────────┘
```

## 📋 Prerequisitos

- **Terraform**: v1.0 o superior ([instalar](https://www.terraform.io/downloads))
- **AWS CLI**: v2.0 o superior ([instalar](https://aws.amazon.com/cli/))
- **Cuenta AWS** con permisos para crear:
  - IAM Roles y Policies
  - Lambda Functions
  - CloudWatch Logs

## 🔐 Configuración de Credenciales AWS

### 1. Crear usuario IAM en AWS Console

1. Ir a [IAM Console](https://console.aws.amazon.com/iam/)
2. Crear nuevo usuario (ej: `terraform-labs`)
3. Adjuntar políticas managed:
   - `IAMFullAccess`
   - `AWSLambda_FullAccess`
   - `CloudWatchLogsFullAccess`
4. Crear Access Keys (Security credentials → Create access key)
5. Guardar `Access Key ID` y `Secret Access Key`

### 2. Configurar archivo .env

Crear archivo `.env` en la raíz del proyecto:

```bash
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_DEFAULT_REGION=us-east-1
```

⚠️ **IMPORTANTE**: Nunca subas `.env` a Git (ya está en `.gitignore`)

## 🚀 Instrucciones de Despliegue

### 1. Preparar el código Lambda

```bash
# Dar permisos de ejecución al script de build
chmod +x build.sh

# Ejecutar script (valida .env y crea lambda.zip)
./build.sh
```

### 2. Cargar credenciales AWS

**Opción A - Usar source directamente:**
```bash
# Cargar variables de entorno
source .env

# Verificar credenciales
aws sts get-caller-identity
```

**Opción B - Usar script helper (recomendado):**
```bash
# Carga credenciales y verifica automáticamente
source ./load-credentials.sh
```

💡 **Tip**: Si `source .env` no funciona, asegúrate de que el archivo tenga el prefijo `export` en cada línea y no contenga comentarios.

### 3. Inicializar Terraform

```bash
# Descargar providers (AWS, random)
terraform init

# Formatear código Terraform
terraform fmt

# Validar sintaxis
terraform validate
```

### 4. Desplegar infraestructura

```bash
# Ver plan de recursos a crear
terraform plan

# Aplicar cambios (confirmar con 'yes')
terraform apply
```

Recursos que se crearán:
- ✅ `random_id.suffix` - sufijo único para IAM role
- ✅ `aws_iam_role.lambda_role` - role para Lambda
- ✅ `aws_iam_role_policy_attachment.lambda_logs` - permisos CloudWatch
- ✅ `aws_lambda_function.main` - función Lambda

## 🧪 Verificación y Testing

### Invocación Síncrona (RequestResponse)

```bash
# Invocar Lambda y esperar respuesta
aws lambda invoke \
  --function-name $(terraform output -raw lambda_function_name) \
  --invocation-type RequestResponse \
  --payload '{"testType":"synchronous","data":"example"}' \
  response.json

# Ver respuesta
cat response.json
```

**¿Qué sucede?**: AWS CLI espera a que Lambda termine de ejecutarse y devuelve la respuesta completa. Útil para APIs REST donde necesitas respuesta inmediata.

### Invocación Asíncrona (Event)

```bash
# Invocar Lambda sin esperar ejecución (fire-and-forget)
aws lambda invoke \
  --function-name $(terraform output -raw lambda_function_name) \
  --invocation-type Event \
  --payload '{"testType":"asynchronous","data":"background"}' \
  response.json
```

**¿Qué sucede?**: AWS CLI retorna inmediatamente después de encolar el evento. Lambda se ejecuta en background. Útil para procesamiento asíncrono, triggers de S3, SNS, EventBridge.

### Ver Logs en CloudWatch

```bash
# Streaming de logs en tiempo real
aws logs tail $(terraform output -raw cloudwatch_log_group_name) --follow

# En otra terminal, invocar Lambda varias veces para ver logs aparecer
```

**Observa**: Logs estructurados en JSON con `message`, `event`, `timestamp`, y `requestId` único por invocación.

## 📚 Conceptos Aprendidos

### Trust Policies vs Resource Policies

- **Trust Policy** (`assume_role_policy`): Define QUIÉN puede asumir un IAM role
  - En nuestro caso: el servicio Lambda (`lambda.amazonaws.com`)
  - Usa acción `sts:AssumeRole`
  
- **Resource Policy**: Define QUÉ puede hacer el role (permisos)
  - En nuestro caso: managed policy `AWSLambdaBasicExecutionRole`

### Managed Policies vs Inline Policies

- **Managed Policy**: Creada y mantenida por AWS
  - Ejemplo: `AWSLambdaBasicExecutionRole` incluye permisos de CloudWatch Logs
  - Ventaja: actualizaciones automáticas, reutilizable
  
- **Inline Policy**: Custom, embebida en el role
  - Útil para permisos específicos no cubiertos por managed policies

### Random ID para Unicidad

IAM roles tienen límite de nombres únicos por cuenta. Si destruyes y recreas rápido, AWS puede tener el nombre "reservado" temporalmente. `random_id` añade sufijo único (ej: `fastlabs-hello-lambda-role-a3f2c8b1`) evitando conflictos.

### Lambda Handler Contract

```javascript
exports.handler = async (event, context) => {
  // event: datos del invocador (payload)
  // context: metadata (requestId, functionName, etc)
  
  return {
    statusCode: 200,  // código HTTP
    body: 'ok'        // debe ser string
  };
};
```

### Logging Estructurado

```javascript
console.log(JSON.stringify({ message, event, timestamp }));
```

Beneficios:
- Parseable por CloudWatch Insights
- Queries complejas (filtrar por campos)
- Mejor para sistemas de monitoreo

### CloudWatch Log Groups Automáticos

Lambda crea automáticamente el Log Group `/aws/lambda/<function-name>` en la primera invocación. Los permisos `logs:CreateLogGroup`, `logs:CreateLogStream`, y `logs:PutLogEvents` lo permiten.

### Invocación Síncrona vs Asíncrona

| Característica | Síncrona (RequestResponse) | Asíncrona (Event) |
|---|---|---|
| **Espera respuesta** | ✅ Sí | ❌ No (fire-and-forget) |
| **Latencia** | Alta (espera ejecución) | Baja (retorna inmediatamente) |
| **Reintentos** | Manual | Automáticos (2 veces) |
| **Casos de uso** | APIs REST, validaciones | Procesamiento background, triggers |

## 🧹 Limpieza de Recursos

**IMPORTANTE**: Para evitar costos innecesarios en tu cuenta AWS personal:

```bash
# Destruir todos los recursos creados
terraform destroy

# Confirmar con 'yes'
```

Esto eliminará:
- Lambda function
- IAM role (con random suffix)
- Policy attachments
- Random ID resource

**Nota**: CloudWatch Log Group puede permanecer (costo mínimo). Para eliminarlo manualmente:

```bash
aws logs delete-log-group --log-group-name /aws/lambda/fastlabs-hello-lambda
```

## 📊 Tags para Organización

Todos los recursos tienen tags:
- `Environment = "learning"` - identifica ambiente de desarrollo
- `Project = "fastlabs"` - agrupa recursos del proyecto

Beneficios:
- **Cost tracking**: ver costos por proyecto en AWS Cost Explorer
- **Organización**: filtrar recursos en AWS Console
- **Automation**: scripts pueden actuar sobre tags

## 🔍 Troubleshooting

### Error: "Unable to locate credentials" al ejecutar source .env

**Causa**: El archivo `.env` no tiene el prefijo `export` o contiene comentarios que interfieren

**Solución**: 
```bash
# Tu .env debe verse así (SIN comentarios):
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-east-1
```

**Alternativa**: Usa el script helper:
```bash
source ./load-credentials.sh
```

### Error: "AccessDeniedException" al hacer terraform apply

**Causa**: Credenciales AWS no tienen permisos suficientes

**Solución**: Verificar que el usuario IAM tenga las políticas mencionadas en prerequisitos

### Error: "EntityAlreadyExists" al crear IAM role

**Causa**: Role con ese nombre ya existe (destroy anterior incompleto)

**Solución**: El `random_id` debería evitar esto. Si persiste, cambiar `lambda_function_name` en `variables.tf`

### Lambda invocada pero sin logs en CloudWatch

**Causa**: Permisos insuficientes en IAM role

**Solución**: Verificar que `aws_iam_role_policy_attachment` esté aplicado correctamente con `terraform state list`

### build.sh falla: "command not found: zip"

**Causa**: Comando `zip` no instalado (raro en macOS/Linux)

**Solución macOS**: `brew install zip`

## 📝 Comandos Útiles

```bash
# Ver estado actual de Terraform
terraform show

# Listar recursos en state
terraform state list

# Ver output específico
terraform output lambda_function_name

# Formatear y validar antes de apply
terraform fmt && terraform validate

# Ver logs sin follow
aws logs tail /aws/lambda/fastlabs-hello-lambda --since 5m

# Describir función Lambda
aws lambda get-function --function-name fastlabs-hello-lambda

# Ver configuración de IAM role
aws iam get-role --role-name <role-name-from-output>
```

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor lee [CONTRIBUTING.md](CONTRIBUTING.md) para conocer el proceso.

### Formas de contribuir:
- 🐛 Reportar bugs
- 💡 Sugerir mejoras o nuevas funcionalidades
- 📖 Mejorar la documentación
- ✨ Enviar pull requests

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👨‍💻 Autor

**David Paredes**
- GitHub: [@davidparedes](https://github.com/davidparedes)

## 🙏 Agradecimientos

- [HashiCorp Terraform](https://www.terraform.io/) - Infrastructure as Code tool
- [AWS Lambda](https://aws.amazon.com/lambda/) - Serverless compute service
- Comunidad de AWS y Terraform por los recursos educativos

## 🔗 Recursos Adicionales

- [ARCHITECTURE.md](ARCHITECTURE.md) - Documentación técnica detallada
- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [CloudWatch Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html)

---

**Proyecto completado** ✅ Has aprendido Terraform, Lambda, IAM, CloudWatch Logs, invocaciones síncronas/asíncronas, y mejores prácticas de IaC. 🎉

⭐ **Si este proyecto te ayudó, considera darle una estrella en GitHub** ⭐

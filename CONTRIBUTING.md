# Contributing to AWS Terraform FastLabs

¡Gracias por tu interés en contribuir! 🎉

## 🤝 Cómo Contribuir

### Reportar Bugs

Si encuentras un bug, por favor abre un issue incluyendo:
- Descripción clara del problema
- Pasos para reproducirlo
- Versiones de Terraform y AWS CLI que usas
- Logs de error (sin exponer credenciales)

### Sugerir Mejoras

¿Tienes ideas para mejorar el proyecto? Abre un issue con:
- Descripción de la mejora propuesta
- Caso de uso o beneficio
- Posible implementación (opcional)

### Pull Requests

1. **Fork** el repositorio
2. **Crea una rama** para tu feature: `git checkout -b feature/mi-mejora`
3. **Haz cambios** siguiendo las convenciones del proyecto
4. **Testea** tus cambios: `terraform validate` y `terraform plan`
5. **Commit** con mensajes descriptivos: `git commit -m "feat: agregar soporte para múltiples regiones"`
6. **Push** a tu fork: `git push origin feature/mi-mejora`
7. **Abre un Pull Request** con descripción detallada

### Convenciones de Código

#### Terraform
- Usa comentarios inline explicativos (este es un proyecto educativo)
- Formatea con `terraform fmt`
- Valida con `terraform validate`
- Nombres de recursos en snake_case
- Variables con descripciones claras

#### JavaScript (Lambda)
- Usa ES6+ async/await
- Logging estructurado en JSON
- Comentarios JSDoc para funciones exportadas

#### Commit Messages
Seguimos [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` nueva funcionalidad
- `fix:` corrección de bug
- `docs:` cambios en documentación
- `refactor:` refactorización sin cambio de funcionalidad
- `test:` agregar o modificar tests
- `chore:` mantenimiento general

### Testing Local

Antes de abrir un PR, verifica:

```bash
# Formatear código Terraform
terraform fmt -recursive

# Validar sintaxis
terraform validate

# Verificar que build.sh funciona
./build.sh

# Probar despliegue completo
terraform plan
```

## 📝 Code of Conduct

- Sé respetuoso y constructivo
- Valora la diversidad de experiencias y opiniones
- Acepta críticas constructivas
- Enfócate en lo mejor para el proyecto educativo

## 🙋 ¿Preguntas?

Abre un issue con la etiqueta `question` o contacta al maintainer.

---

**¡Gracias por ayudar a mejorar este proyecto educativo!** 🚀

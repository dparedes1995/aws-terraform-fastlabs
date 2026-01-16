# Outputs de Terraform - valores útiles después del deployment
# Estos outputs facilitan el testing y verificación sin buscar en AWS Console

output "lambda_function_arn" {
  description = "ARN completo de la función Lambda (Amazon Resource Name)"
  value       = aws_lambda_function.main.arn
}

output "lambda_function_name" {
  description = "Nombre de la función Lambda - usar en comandos AWS CLI"
  value       = aws_lambda_function.main.function_name
}

output "lambda_role_arn" {
  description = "ARN del IAM role asociado a Lambda"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_name" {
  description = "Nombre del IAM role (incluye random suffix generado)"
  value       = aws_iam_role.lambda_role.name
}

output "cloudwatch_log_group_name" {
  description = "Nombre del CloudWatch Log Group (creado automáticamente por Lambda)"
  value       = "/aws/lambda/${aws_lambda_function.main.function_name}"
}


output "kafka_credentials_arn" {
  value = aws_secretsmanager_secret.kafka_credentials.arn
}

output "schema_registry_credentials_arn" {
  value = length(var.schema_registry_username) > 0 ? aws_secretsmanager_secret.schema_registry_credentials[0].arn : ""
}
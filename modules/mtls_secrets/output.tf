output "kafka_credentials_arn" {
  value = aws_secretsmanager_secret.kafka_user_certificate.arn
}

output "kafka_ca_secret_arn" {
  value = length(var.ca_certificate) > 0 ? aws_secretsmanager_secret.kafka_ca_certificate[0].arn : ""
}

output "schema_registry_credentials_arn" {
  value = length(var.schema_registry_username) > 0 ? aws_secretsmanager_secret.schema_registry_credentials[0].arn : ""
}
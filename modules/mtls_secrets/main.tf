/**
 * # mTLS secrets for the Kafka2SQS module
 */

resource "aws_secretsmanager_secret" "kafka_user_certificate" {
  name = var.user_certificate_secret_name
}

resource "aws_secretsmanager_secret_version" "kafka_user_certificate" {
  secret_id = aws_secretsmanager_secret.kafka_user_certificate.id
  secret_string = jsonencode({
    certificate = var.user_certificate
    privateKey  = var.private_key
  })
}

resource "aws_secretsmanager_secret" "kafka_ca_certificate" {
  name = "kafka_ca_certificate"
}

resource "aws_secretsmanager_secret_version" "kafka_ca_certificate" {
  secret_id = aws_secretsmanager_secret.kafka_ca_certificate.id
  secret_string = jsonencode({
    certificate = var.ca_certificate
  })
}

resource "aws_secretsmanager_secret" "schema_registry_credentials" {
  name = var.schema_registry_secret_name
}

resource "aws_secretsmanager_secret_version" "schema_registry_credentials" {
  secret_id = aws_secretsmanager_secret.schema_registry_credentials.id
  secret_string = jsonencode({
    username = var.schema_registry_username
    password = var.schema_registry_password
  })
}
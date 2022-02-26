resource "aws_secretsmanager_secret" "kafka_credentials" {
  name = var.kafka_secret_name
}

resource "aws_secretsmanager_secret_version" "kafka_credentials" {
  secret_id = aws_secretsmanager_secret.kafka_credentials.id
  secret_string = jsonencode({
    username = var.kafka_username
    password = var.kafka_password
  })
}

resource "aws_secretsmanager_secret" "schema_registry_credentials" {
  count = length(var.schema_registry_username) > 0 ? 1 : 0
  name  = var.schema_registry_secret_name
}

resource "aws_secretsmanager_secret_version" "schema_registry_credentials" {
  count     = length(var.schema_registry_username) > 0 ? 1 : 0
  secret_id = aws_secretsmanager_secret.schema_registry_credentials[0].id
  secret_string = jsonencode({
    username = var.schema_registry_username
    password = var.schema_registry_password
  })
}

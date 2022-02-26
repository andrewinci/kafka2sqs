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
  count = length(var.ca_certificate) > 0 ? 1 : 0
  name  = "kafka_ca_certificate"
}

resource "aws_secretsmanager_secret_version" "kafka_ca_certificate" {
  count     = length(var.ca_certificate) > 0 ? 1 : 0
  secret_id = aws_secretsmanager_secret.kafka_ca_certificate[0].id
  secret_string = jsonencode({
    certificate = var.ca_certificate
  })
}

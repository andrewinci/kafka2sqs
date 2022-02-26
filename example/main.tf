variable "certificate" {
  type = map(string)
  default = {
    certificate        = "PEM encoded certificate"
    privateKey         = "PEM PKCS8 private key"
    privateKeyPassword = "(Optional)"
  }
}

variable "ca_certificate" {
  type = map(string)
  default = {
    certificate = "PEM encoded certificate"
  }
}

resource "aws_secretsmanager_secret" "kafka_user_certificate" {
  name = "kafka_user_certificate"
}

resource "aws_secretsmanager_secret_version" "kafka_user_certificate" {
  secret_id     = aws_secretsmanager_secret.kafka_user_certificate.id
  secret_string = jsonencode(var.certificate)
}

resource "aws_secretsmanager_secret" "kafka_ca_certificate" {
  name = "kafka_ca_certificate"
}

resource "aws_secretsmanager_secret_version" "kafka_ca_certificate" {
  secret_id     = aws_secretsmanager_secret.kafka_ca_certificate.id
  secret_string = jsonencode(var.ca_certificate)
}

module "lambda_to_sqs" {
  #source                       = "https://github.com/andrewinci/lambda-kafka2sqs/releases/download/v1.0.1/module.zip"
  source                       = "../module"
  function_name                = "consumer"
  kafka_topic                  = "example"
  kafka_endpoints              = "kafka1.example.com:9092,kafka2.example.com:9092"
  kafka_subnet_ids             = ["subnet1"]
  kafka_sg_ids                 = ["sg-example"]
  kafka_certificate_secret_arn = aws_secretsmanager_secret.kafka_user_certificate.arn
  kafka_ca_secret_arn          = aws_secretsmanager_secret.kafka_ca_certificate.arn
}

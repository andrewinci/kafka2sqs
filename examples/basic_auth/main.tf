variable "endpoints" {
  type    = string
  default = "example.confluent.cloud:9092"
}

variable "basic_auth" {
  type = map(string)
  default = {
    username = "key"
    password = "password"
  }
}

resource "aws_secretsmanager_secret" "kafka_basic_auth" {
  name = "kafka_basic_auth"
}

resource "aws_secretsmanager_secret_version" "kafka_user_certificate" {
  secret_id     = aws_secretsmanager_secret.kafka_basic_auth.id
  secret_string = jsonencode(var.basic_auth)
}

module "lambda_to_sqs" {
  #source                       = "https://github.com/andrewinci/lambda-kafka2sqs/releases/download/v1.0.1/module.zip"
  source                    = "../../module"
  function_name             = "consumer"
  kafka_topic               = "test"
  kafka_endpoints           = var.endpoints
  kafka_authentication_type = "BASIC"
  kafka_credentials_arn     = aws_secretsmanager_secret.kafka_basic_auth.arn
}

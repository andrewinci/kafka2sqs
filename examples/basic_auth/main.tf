variable "kafka_endpoints" {
  type    = string
  default = "example.confluent.cloud:9092"
}

variable "schema_registry_endpoint" {
  type    = string
  default = "https://schemaregistry.confluent.cloud:9093"
}


variable "schema_registry_basic_auth" {
  type = map(string)
  default = {
    username = "key"
    password = "password"
  }
}

variable "kafka_basic_auth" {
  type = map(string)
  default = {
    username = "key"
    password = "password"
  }
}

resource "aws_secretsmanager_secret" "kafka_basic_auth" {
  name = "kafka_basic_auth"
}

resource "aws_secretsmanager_secret_version" "kafka_basic_auth" {
  secret_id     = aws_secretsmanager_secret.kafka_basic_auth.id
  secret_string = jsonencode(var.kafka_basic_auth)
}

resource "aws_secretsmanager_secret" "schema_registry_basic_auth" {
  name = "schema_registry_basic_auth"
}

resource "aws_secretsmanager_secret_version" "schema_registry_basic_auth" {
  secret_id     = aws_secretsmanager_secret.schema_registry_basic_auth.id
  secret_string = jsonencode(var.schema_registry_basic_auth)
}

module "lambda_to_sqs" {
  #source                       = "https://github.com/andrewinci/lambda-kafka2sqs/releases/download/v1.0.1/module.zip"
  source                          = "../../module"
  function_name                   = "consumer"
  kafka_endpoints                 = var.kafka_endpoints
  kafka_authentication_type       = "BASIC"
  kafka_credentials_arn           = aws_secretsmanager_secret.kafka_basic_auth.arn
  schema_registry_endpoint        = var.schema_registry_endpoint
  schema_registry_credentials_arn = aws_secretsmanager_secret.schema_registry_basic_auth.arn
  kafka_topics = [
    { topic_name = "test", is_avro = true },
    { topic_name = "test-2", is_avro = false }
  ]
}

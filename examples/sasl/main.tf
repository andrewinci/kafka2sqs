module "sasl_secrets" {
  source                   = "https://github.com/andrewinci/lambda-kafka2sqs/releases/download/v1.10.1/module.zip//sasl_secrets"
  kafka_username           = var.kafka_username
  kafka_password           = var.kafka_password
  schema_registry_username = var.schema_registry_username
  schema_registry_password = var.schema_registry_password
}

module "lambda_to_sqs" {
  source                          = "https://github.com/andrewinci/lambda-kafka2sqs/releases/download/v1.10.1/module.zip//lambda"
  function_name                   = "consumer"
  kafka_endpoints                 = var.kafka_endpoints
  kafka_authentication_type       = "SASL"
  kafka_credentials_arn           = module.sasl_secrets.kafka_credentials_arn
  schema_registry_endpoint        = var.schema_registry_endpoint
  schema_registry_credentials_arn = module.sasl_secrets.schema_registry_credentials_arn
  kafka_topics = [
    { topic_name = "test", is_avro = true },
    { topic_name = "test-2", is_avro = false }
  ]
}

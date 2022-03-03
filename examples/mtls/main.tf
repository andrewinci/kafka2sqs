module "mtls_secrets" {
  source                   = "https://github.com/andrewinci/kafka2sqs/releases/download/v2.3.0/module.zip//mtls_secrets"
  user_certificate         = var.kafka_certificate
  private_key              = var.kafka_private_key
  ca_certificate           = var.kafka_ca_certificate
  schema_registry_username = var.schema_registry_username
  schema_registry_password = var.schema_registry_password
}

module "lambda_to_sqs" {
  source                          = "https://github.com/andrewinci/kafka2sqs/releases/download/v2.3.0/module.zip//lambda"
  function_name                   = "consumer"
  kafka_endpoints                 = var.kafka_endpoints
  kafka_authentication_type       = "mTLS"
  kafka_credentials_arn           = module.mtls_secrets.kafka_credentials_arn
  kafka_ca_secret_arn             = module.mtls_secrets.kafka_ca_secret_arn
  schema_registry_endpoint        = var.schema_registry_endpoint
  schema_registry_credentials_arn = module.mtls_secrets.schema_registry_credentials_arn
  kafka_topics                    = [{ topic_name = "my_topic", is_avro = true }]
}

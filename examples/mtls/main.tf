module "mtls_secrets" {
  source           = "https://github.com/andrewinci/lambda-kafka2sqs/releases/download/v2.0.0/module.zip//mtls_secrets"
  user_certificate = "<PEM encoded certificate>"
  private_key      = "<PEM PKCS8 private key>"
  ca_certificate   = "<PEM encoded certificate>"
}

module "lambda_to_sqs" {
  source                    = "https://github.com/andrewinci/lambda-kafka2sqs/releases/download/v2.0.0/module.zip//lambda"
  function_name             = "consumer"
  kafka_endpoints           = "kafka1.example.com:9092,kafka2.example.com:9092"
  kafka_subnet_ids          = ["subnet1"]
  kafka_sg_ids              = ["sg-example"]
  kafka_authentication_type = "mTLS"
  kafka_credentials_arn     = module.mtls_secrets.kafka_credentials_arn
  kafka_ca_secret_arn       = module.mtls_secrets.kafka_ca_secret_arn
  kafka_topics              = [{ topic_name = "test", is_avro = true }]
}
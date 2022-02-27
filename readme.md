# WIP: Lambda Kafka2SQS

Terraform module that creates a lambda triggered by kafka topics.  
The lambda deserialize any received message and publish them into an SQS queue.

## Basic lambda usage

See module documentation [here](./modules/lambda/readme.md)

```hcl
module "lambda_to_sqs" {
  source                    = "https://github.com/andrewinci/lambda-kafka2sqs/releases/latest/download/module.zip//lambda"
  function_name             = "consumer"
  kafka_endpoints           = "kafka1.example.com:9092,kafka2.example.com:9092"
  kafka_subnet_ids          = ["subnet1"]
  kafka_sg_ids              = ["sg-example"]
  kafka_authentication_type = "mTLS"
  kafka_credentials_arn     = aws_secretsmanager_secret.kafka_user_certificate.arn
  kafka_ca_secret_arn       = aws_secretsmanager_secret.kafka_ca_certificate.arn
  kafka_topics              = [{ topic_name = "test", is_avro = true }]
}
```

## SASL auth example (Confluent cloud)

See module documentation [here](./modules/sasl_secrets/readme.md)

```hcl
module "sasl_secrets" {
  source                   = "https://github.com/andrewinci/lambda-kafka2sqs/releases/latest/download/module.zip//sasl_secrets"
  kafka_username           = "kafka_username"
  kafka_password           = "kafka_password"
  schema_registry_username = "schema_registry_username"
  schema_registry_password = "schema_registry_password"
}

module "lambda_to_sqs" {
  source                          = "https://github.com/andrewinci/lambda-kafka2sqs/releases/latest/download/module.zip//lambda"
  function_name                   = "consumer"
  kafka_endpoints                 = "whatever.europe-west1.gcp.confluent.cloud:9092"
  kafka_authentication_type       = "SASL"
  kafka_credentials_arn           = module.sasl_secrets.kafka_credentials_arn
  schema_registry_endpoint        = "https://schema_registry.endpoint.com"
  schema_registry_credentials_arn = module.sasl_secrets.schema_registry_credentials_arn
  kafka_topics = [
    { topic_name = "test", is_avro = true },
    { topic_name = "test-2", is_avro = false }
  ]
}
```

## mTLS example (Aiven)

See module documentation [here](./modules/mtls_secrets/readme.md)

```hcl
module "mtls_secrets" {
  source           = "https://github.com/andrewinci/lambda-kafka2sqs/releases/latest/download/module.zip//mtls_secrets"
  user_certificate = "<PEM encoded certificate>"
  private_key      = "<PEM PKCS8 private key>"
  ca_certificate   = "<PEM encoded certificate>"
}

module "lambda_to_sqs" {
  source                    = "https://github.com/andrewinci/lambda-kafka2sqs/releases/latest/download/module.zip//lambda"
  function_name             = "consumer"
  kafka_endpoints           = "kafka1.example.com:9092,kafka2.example.com:9092"
  kafka_subnet_ids          = ["subnet1"]
  kafka_sg_ids              = ["sg-example"]
  kafka_authentication_type = "mTLS"
  kafka_credentials_arn     = module.mtls_secrets.kafka_credentials_arn
  kafka_ca_secret_arn       = module.mtls_secrets.kafka_ca_secret_arn
  kafka_topics              = [{ topic_name = "test", is_avro = true }]
}
```

# Dev

Package the terraform module with
```bash
make clean && make
```

Init the python virtualenv with
```bash
make venv && source .kafka2sqs/bin/activate
```

Lint the code with
```bash
make lint
```

Run tests and check the lint with
```bash
make && make check
```

Clean up with
```bash
make clean
```

Generate the documentation with
```bash
make docs
```

## Credits

The documentation is generated with [terraform-docs](https://terraform-docs.io/) 
<h1 align="center">Kafka2SQS</h1>

<p align="center">
<a href="https://github.com/andrewinci/kafka2sqs/actions/workflows/package.yml"><img alt="Package tf module" src="https://github.com/andrewinci/kafka2sqs/actions/workflows/package.yml/badge.svg"></a>
<a href="https://snyk.io/test/github/andrewinci/kafka2sqs"><img alt="Snyk" src="https://snyk.io/test/github/andrewinci/kafka2sqs/badge.svg"></a>
<a href="https://github.com/psf/black"><img alt="Code style: black" src="https://img.shields.io/badge/code%20style-black-000000.svg"></a>
</p>

Terraform modules to configures an AWS lambda that connects Kafka to SQS.

The lambda is triggered by the AWS Kafka event source. It parses the kafka record from Avro or string and produce a new message
with the result to SQS. The parsed key and value are added to the original record received from the event source under the fields
`parsed_key` and `parsed_value`. 

The `parsed_key` is always a string while the `parsed_value` can be an Avro json if the source was avro 
otherwise a string.

Any process error is attached to the original event as well before it is sent to the DLQ with the field `process_exception`.

## Main features
- Serverless consumer
- Support for Avro and Schema Registry
- DLQ for poisoned pills and parsing errors
- Helper modules to easily configure the kafka credentials
- Support deploy lambda in a VPC subnet

## Basic lambda usage

See module documentation [here](./modules/lambda/readme.md)

```hcl
module "lambda_to_sqs" {
  source                    = "https://github.com/andrewinci/kafka2sqs/releases/download/v2.1.1/module.zip//lambda"
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
  source                   = "https://github.com/andrewinci/kafka2sqs/releases/download/v2.1.1/module.zip//sasl_secrets"
  kafka_username           = "kafka_username"
  kafka_password           = "kafka_password"
  schema_registry_username = "schema_registry_username"
  schema_registry_password = "schema_registry_password"
}

module "lambda_to_sqs" {
  source                          = "https://github.com/andrewinci/kafka2sqs/releases/download/v2.1.1/module.zip//lambda"
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
  source                   = "https://github.com/andrewinci/kafka2sqs/releases/download/v2.1.1/module.zip//mtls_secrets"
  user_certificate         = var.kafka_certificate
  private_key              = var.kafka_private_key
  ca_certificate           = var.kafka_ca_certificate
  schema_registry_username = var.schema_registry_username
  schema_registry_password = var.schema_registry_password
}

module "lambda_to_sqs" {
  source          = "https://github.com/andrewinci/kafka2sqs/releases/download/v2.1.1/module.zip//lambda"
  function_name   = "consumer"
  kafka_endpoints = var.kafka_endpoints
  kafka_authentication_type       = "mTLS"
  kafka_credentials_arn           = module.mtls_secrets.kafka_credentials_arn
  kafka_ca_secret_arn             = module.mtls_secrets.kafka_ca_secret_arn
  schema_registry_endpoint        = var.schema_registry_endpoint
  schema_registry_credentials_arn = module.mtls_secrets.schema_registry_credentials_arn
  kafka_topics                    = [{ topic_name = "my_topic", is_avro = true }]
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
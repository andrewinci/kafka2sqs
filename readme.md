# WIP: Lambda Kafka2SQS

Terraform module that creates a lambda triggered by kafka topics.  
The lambda deserialize any received message and publish them into an SQS queue.

## Getting started

### Basic auth example (Confluent cloud)

See full example at [example.tf](./examples/basic_auth/main.tf)

```hcl
module "lambda_to_sqs" {
  source                    = "https://github.com/andrewinci/lambda-kafka2sqs/releases/download/v<version>/module.zip"
  function_name             = "consumer"
  kafka_topics              = [{ topic_name = "test", is_avro = true }]
  kafka_endpoints           = "example.confluent.cloud:9092"
  kafka_authentication_type = "BASIC"
  kafka_credentials_arn     = aws_secretsmanager_secret.kafka_basic_auth.arn
}
```

### mTLS example (Aiven)

See full example at [example.tf](./examples/mtls/main.tf)

```hcl
module "lambda_to_sqs" {
  source                       = "https://github.com/andrewinci/lambda-kafka2sqs/releases/download/v<version>/module.zip"
  function_name                = "consumer"
  kafka_endpoints              = "kafka1.example.com:9092,kafka2.example.com:9092"
  kafka_topics                 = [{ topic_name = "example", is_avro = false }]
  kafka_subnet_ids             = ["subnet1"]
  kafka_sg_id                  = "sg-example"
  kafka_authentication_type    = "mTLS"
  kafka_credentials_arn        = aws_secretsmanager_secret.kafka_basic_auth.arn
  kafka_ca_secret_arn          = aws_secretsmanager_secret.kafka_ca_certificate.arn
  
}
```

# Dev

Package the terraform module with
```bash
make clean && make
```

Init the python virtualenv with
```bash
make venv && source kafka2sqs/bin/activate
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

The documentation is generated with [terraform-docs](https://terraform-docs.io/) 
```bash
terraform-docs markdown module
```
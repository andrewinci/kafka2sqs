# Lambda Kafka2SQS

Terraform module that creates a lambda triggered by kafka topics.
The lambda deserialize any received message and publish them into an SQS queue.

## Getting started

```hcl
module "lambda_to_sqs" {
  source = "https://github.com/andrewinci/lambda-kafka2sqs/releases/download/v1.0.1/module.zip"
  kafka_topic = "example"
  kafka_endpoints = "kafka1.example.com:9092,kafka2.example.com:9092"
  kafka_subnet_ids = ["subnet1"]
  kafka_sg_id = "arn:...."
  kafka_certificate_secret_arn = "arn:..."
  kafka_ca_secret_arn = "arn:...."
}
```


## Dev

### Requirements
- python3
- terraform

Package the lambda with
```bash
make
```

Init the python virtualenv with
```bash
make venv && source kafka2sqs/bin/activate
```

Lint the code with
```bash
make lint
```

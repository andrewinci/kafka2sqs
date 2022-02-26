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
  kafka_topic               = "test"
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
  kafka_topic                  = "example"
  kafka_endpoints              = "kafka1.example.com:9092,kafka2.example.com:9092"
  kafka_subnet_ids             = ["subnet1"]
  kafka_sg_id                  = "sg-example"
  kafka_authentication_type    = "mTLS"
  kafka_credentials_arn        = aws_secretsmanager_secret.kafka_basic_auth.arn
  kafka_ca_secret_arn          = aws_secretsmanager_secret.kafka_ca_certificate.arn
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.consumer_lambda_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.secrets_getter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.vpc_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_event_source_mapping.event_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Lambda function name | `string` | `"kafka-consumer"` | no |
| <a name="input_kafka_authentication_type"></a> [kafka\_authentication\_type](#input\_kafka\_authentication\_type) | The authentication to perform to connect to kafka. Possible values are: "BASIC" or "mTLS". | `string` | n/a | yes |
| <a name="input_kafka_batch_size"></a> [kafka\_batch\_size](#input\_kafka\_batch\_size) | The largest number of records that Lambda will retrieve from each kafka topic | `number` | `10` | no |
| <a name="input_kafka_ca_secret_arn"></a> [kafka\_ca\_secret\_arn](#input\_kafka\_ca\_secret\_arn) | The arn of the secret containing the ca certificate in PEM format | `string` | `""` | no |
| <a name="input_kafka_credentials_arn"></a> [kafka\_credentials\_arn](#input\_kafka\_credentials\_arn) | The arn of the secret containing the kafka credentials. The content dependes on the "kafka\_authentication\_type" var. | `string` | `""` | no |
| <a name="input_kafka_endpoints"></a> [kafka\_endpoints](#input\_kafka\_endpoints) | Comma separated kafka endpoints <ip>:<port> | `string` | n/a | yes |
| <a name="input_kafka_sg_ids"></a> [kafka\_sg\_ids](#input\_kafka\_sg\_ids) | List of security group id to access kafka | `list(string)` | `[]` | no |
| <a name="input_kafka_starting_position"></a> [kafka\_starting\_position](#input\_kafka\_starting\_position) | The position in the stream where AWS Lambda should start reading. Supported values are: LATEST, TRIM\_HORIZON | `string` | `"TRIM_HORIZON"` | no |
| <a name="input_kafka_subnet_ids"></a> [kafka\_subnet\_ids](#input\_kafka\_subnet\_ids) | List of subnets ids to use for the kafka event source | `list(string)` | `[]` | no |
| <a name="input_kafka_topic"></a> [kafka\_topic](#input\_kafka\_topic) | Kafka topic name | `string` | n/a | yes |
| <a name="input_log_group_retention_days"></a> [log\_group\_retention\_days](#input\_log\_group\_retention\_days) | Cloudwatch log group retention in days | `number` | `30` | no |

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
make check
```

Clean up with
```bash
make clean
```

The documentation is generated with [terraform-docs](https://terraform-docs.io/) 
```bash
terraform-docs markdown module
```
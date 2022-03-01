# SASL secrets for the Kafka2SQS module

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.74.3 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kafka_password"></a> [kafka\_password](#input\_kafka\_password) | SASL PLAIN username password | `string` | n/a | yes |
| <a name="input_kafka_secret_name"></a> [kafka\_secret\_name](#input\_kafka\_secret\_name) | Name of the secretsmanager certificate | `string` | `"kafka_credentials"` | no |
| <a name="input_kafka_username"></a> [kafka\_username](#input\_kafka\_username) | SASL PLAIN username | `string` | n/a | yes |
| <a name="input_schema_registry_password"></a> [schema\_registry\_password](#input\_schema\_registry\_password) | Schema registry password | `string` | n/a | yes |
| <a name="input_schema_registry_secret_name"></a> [schema\_registry\_secret\_name](#input\_schema\_registry\_secret\_name) | Name of the secretsmanager certificate | `string` | `"schema_registry_credentials"` | no |
| <a name="input_schema_registry_username"></a> [schema\_registry\_username](#input\_schema\_registry\_username) | Schema registry username | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kafka_credentials_arn"></a> [kafka\_credentials\_arn](#output\_kafka\_credentials\_arn) | n/a |
| <a name="output_schema_registry_credentials_arn"></a> [schema\_registry\_credentials\_arn](#output\_schema\_registry\_credentials\_arn) | n/a |
## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.kafka_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.schema_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.kafka_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.schema_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

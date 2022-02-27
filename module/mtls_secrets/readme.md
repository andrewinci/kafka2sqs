# mTLS secrets for the Kafka2SQS module

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ca_certificate"></a> [ca\_certificate](#input\_ca\_certificate) | PEM encoded CA certificate | `string` | `""` | no |
| <a name="input_ca_certificate_secret_name"></a> [ca\_certificate\_secret\_name](#input\_ca\_certificate\_secret\_name) | Name of the secretsmanager certificate | `string` | `"kafka_ca_certificate"` | no |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | PEM PKCS8 private key | `string` | n/a | yes |
| <a name="input_private_key_password"></a> [private\_key\_password](#input\_private\_key\_password) | todo: support | `string` | `""` | no |
| <a name="input_user_certificate"></a> [user\_certificate](#input\_user\_certificate) | PEM encoded user certificate | `string` | n/a | yes |
| <a name="input_user_certificate_secret_name"></a> [user\_certificate\_secret\_name](#input\_user\_certificate\_secret\_name) | Name of the secretsmanager certificate | `string` | `"kafka_user_certificate"` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kafka_ca_secret_arn"></a> [kafka\_ca\_secret\_arn](#output\_kafka\_ca\_secret\_arn) | n/a |
| <a name="output_kafka_credentials_arn"></a> [kafka\_credentials\_arn](#output\_kafka\_credentials\_arn) | n/a |
## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.kafka_ca_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.kafka_user_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.kafka_ca_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.kafka_user_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

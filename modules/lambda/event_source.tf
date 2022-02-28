locals {
  auth_type = lookup({
    SASL = "BASIC_AUTH"
    mTLS = "CLIENT_CERTIFICATE_TLS_AUTH"
  }, var.kafka_authentication_type, "")
  source_access_configuration = concat(
    [for s in var.kafka_vpc_config.subnet_ids : { type = "VPC_SUBNET", uri = "subnet:${s}" }],
    [for s in var.kafka_vpc_config.security_group_ids : { type = "VPC_SECURITY_GROUP", uri = "security_group:${s}" }],
    [{ type = local.auth_type, uri = var.kafka_credentials_arn }],
    length(var.kafka_ca_secret_arn) > 0 ? [{ type = "SERVER_ROOT_CA_CERTIFICATE", uri = var.kafka_ca_secret_arn }] : []
  )
}

resource "aws_lambda_event_source_mapping" "event_source" {
  for_each          = toset([for t in var.kafka_topics : t.topic_name])
  function_name     = aws_lambda_function.lambda.arn
  topics            = [each.value]
  starting_position = var.kafka_starting_position
  batch_size        = var.kafka_batch_size

  self_managed_event_source {
    endpoints = {
      KAFKA_BOOTSTRAP_SERVERS = var.kafka_endpoints
    }
  }

  dynamic "source_access_configuration" {
    for_each = local.source_access_configuration
    iterator = s
    content {
      type = s.value.type
      uri  = s.value.uri
    }
  }
}

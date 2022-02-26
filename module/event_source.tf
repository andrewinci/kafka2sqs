locals {
  kafka_subnets      = [for s in var.kafka_subnet_ids : { type = "VPC_SUBNET", uri = "subnet:${s}" }]
  kafka_sgs          = [for s in var.kafka_sg_ids : { type = "VPC_SECURITY_GROUP", uri = "security_group:${s}" }]
  client_certificate = length(var.kafka_certificate_secret_arn) > 0 ? [{ type = "CLIENT_CERTIFICATE_TLS_AUTH", uri = var.kafka_certificate_secret_arn }] : []
  ca_certificate     = length(var.kafka_ca_secret_arn) > 0 ? [{ type = "SERVER_ROOT_CA_CERTIFICATE", uri = var.kafka_ca_secret_arn }] : []
  source_access_configuration = concat(
    local.kafka_subnets,
    local.kafka_sgs,
    local.client_certificate,
  local.ca_certificate)
}

resource "aws_lambda_event_source_mapping" "event_source" {
  function_name     = aws_lambda_function.lambda.arn
  topics            = [var.kafka_topic]
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
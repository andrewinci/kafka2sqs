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
    for_each = toset(var.kafka_subnet_ids)
    iterator = subnet
    content {
      type = "VPC_SUBNET"
      uri  = "subnet:${subnet.key}"
    }
  }

  source_access_configuration {
    type = "VPC_SECURITY_GROUP"
    uri  = "security_group:${var.kafka_sg_id}"
  }

  source_access_configuration {
    type = "CLIENT_CERTIFICATE_TLS_AUTH"
    uri  = var.kafka_certificate_secret_arn
  }

  source_access_configuration {
    type = "SERVER_ROOT_CA_CERTIFICATE"
    uri  = var.kafka_ca_secret_arn
  }
}
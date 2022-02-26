resource "aws_lambda_function" "consumer" {
  function_name    = var.function_name
  role             = aws_iam_role.role.arn
  handler          = var.function_handler
  source_code_hash = filebase64sha256(var.function_sourcecode)
  filename         = var.function_zip
  runtime          = "python3.9"
  depends_on = [
    aws_cloudwatch_log_group.consumer_lambda_logging
  ]
}

resource "aws_cloudwatch_log_group" "consumer_lambda_logging" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_group_retention_days
}


resource "aws_lambda_event_source_mapping" "lambda" {
  function_name     = aws_lambda_function.consumer.arn
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
    uri  = "security_group:${var.kafka_sg}"
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
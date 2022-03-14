/**
 * # Kafka2SQS Lambda consumer
 */


locals {
  env_topic_config = merge(
    { TOPIC_CONFIGURATION = jsonencode(var.kafka_topics) },
    { SQS_URL = aws_sqs_queue.queue.url, DLQ_URL = aws_sqs_queue.dlq.url },
    length(var.schema_registry_endpoint) > 0 ? { SCHEMA_REGISTRY_URL = var.schema_registry_endpoint } : {},
    length(var.schema_registry_credentials_arn) > 0 ? { SCHEMA_REGISTRY_SECRET_ARN = var.schema_registry_credentials_arn } : {}
  )
  vpc_configured = length(var.function_vpc_config.subnet_ids) > 0 ? ["one"] : []
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.function_name
  role             = aws_iam_role.consumer.arn
  handler          = var.function_handler
  filename         = var.path_to_lambda_zip
  source_code_hash = filesha256(var.path_to_lambda_zip)
  runtime          = var.lambda_runtime
  timeout          = var.function_timeout


  environment {
    variables = local.env_topic_config
  }

  dynamic "vpc_config" {
    for_each = local.vpc_configured
    content {
      subnet_ids         = var.function_vpc_config.subnet_ids
      security_group_ids = var.function_vpc_config.security_group_ids
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.consumer_lambda_logging
  ]
}

resource "aws_cloudwatch_log_group" "consumer_lambda_logging" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_group_retention_days
}

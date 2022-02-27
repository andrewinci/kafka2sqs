/**
 * # Kafka2SQS Lambda consumer
 */


locals {
  function_zip     = "${path.module}/lambda.zip"
  function_handler = "kafka2sqs.main.lambda_handler"
  env_topic_config = merge(
    { TOPIC_CONFIGURATION = jsonencode(var.kafka_topics) },
    length(var.schema_registry_endpoint) > 0 ? { SCHEMA_REGISTRY_URL = var.schema_registry_endpoint } : {},
    length(var.schema_registry_credentials_arn) > 0 ? { SCHEMA_REGISTRY_SECRET_ARN = var.schema_registry_credentials_arn } : {}
  )
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.function_name
  role             = aws_iam_role.role.arn
  handler          = local.function_handler
  filename         = local.function_zip
  source_code_hash = filesha256(local.function_zip)
  runtime          = "python3.9"

  environment {
    variables = local.env_topic_config
  }

  depends_on = [
    aws_cloudwatch_log_group.consumer_lambda_logging
  ]
}

resource "aws_cloudwatch_log_group" "consumer_lambda_logging" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_group_retention_days
}

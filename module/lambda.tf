resource "aws_lambda_function" "lambda" {
  function_name    = var.function_name
  role             = aws_iam_role.role.arn
  handler          = local.function_handler
  source_code_hash = filebase64sha256(local.function_sourcecode)
  filename         = local.function_zip
  runtime          = "python3.9"
  depends_on = [
    aws_cloudwatch_log_group.consumer_lambda_logging
  ]
}

resource "aws_cloudwatch_log_group" "consumer_lambda_logging" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_group_retention_days
}

resource "null_resource" "package_lambda" {
  provisioner "local-exec" {
    command = "cd .. && make"
  }
}
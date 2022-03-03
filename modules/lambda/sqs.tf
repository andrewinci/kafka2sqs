resource "aws_sqs_queue" "queue" {
  name                      = var.queue_name
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
}

resource "aws_sqs_queue" "dlq" {
  name                      = "${var.queue_name}_dlq"
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
}
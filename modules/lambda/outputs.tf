output "queue" {
  description = "Queue output"
  value       = aws_sqs_queue.queue
}

output "dead_letter_queue" {
  description = "DLQ used when the lambda is not able to parse the record."
  value       = aws_sqs_queue.dlq
}

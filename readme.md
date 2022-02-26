# Lambda Kafka2SQS

Terraform module that creates a lambda triggered by kafka topics.
The lambda deserialize any received message and publish them into an SQS queue.
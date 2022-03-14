## Lambda variables

variable "function_name" {
  type        = string
  default     = "kafka-consumer"
  description = "Lambda function name"
}

variable "function_vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default     = { subnet_ids = [], security_group_ids = [] }
  description = "VPC configuration for the lambda"
  validation {
    condition     = var.function_vpc_config != null
    error_message = "The `function_vpc_config` can't be null. Use the default value instead."
  }
}

variable "function_timeout" {
  type        = number
  default     = 60
  description = "Lambda timeout in seconds"
}

variable "log_group_retention_days" {
  type        = number
  default     = 30
  description = "Cloudwatch log group retention in days"
}

variable "path_to_lambda_zip" {
  type        = string
  default     = "${path.module}/lambda.zip"
  description = "Path to zip of source code for lambda"
}


variable "lambda_runtime" {
  type        = string
  default     = "python3.9"
  description = "Runtime environment for lambda - check https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime"
}

variable  "function_handler"{
  type        = string
  default     = "kafka2sqs.main.lambda_handler"
  description = "Lambda function handler"
}


## Kafka variables

variable "kafka_topics" {
  type = list(object({
    topic_name = string
    is_avro    = bool
  }))
  description = "Kafka topics definition"
  validation {
    condition     = length(var.kafka_topics) > 0
    error_message = "At least one kafka topic need to be defined."
  }
}

variable "kafka_batch_size" {
  type        = number
  default     = 10
  description = "The largest number of records that Lambda will retrieve from each kafka topic"
}

variable "kafka_starting_position" {
  type        = string
  default     = "TRIM_HORIZON"
  description = "The position in the stream where AWS Lambda should start reading. Supported values are: LATEST, TRIM_HORIZON"
}

variable "kafka_endpoints" {
  type        = string
  description = "Comma separated kafka endpoints <ip>:<port>"
}

variable "kafka_vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default     = { subnet_ids = [], security_group_ids = [] }
  description = "VPC configuration for the kafka event source"
  validation {
    condition     = var.kafka_vpc_config != null
    error_message = "The `kafka_vpc_config` can't be null. Use the default value instead."
  }
}

variable "kafka_authentication_type" {
  type        = string
  description = "The authentication to perform to connect to kafka. Possible values are: \"SASL\" or \"mTLS\"."
  validation {
    condition     = contains(["SASL", "mTLS"], var.kafka_authentication_type)
    error_message = "Allowed values for kafka_authentication_type are \"SASL\" or \"mTLS\"."
  }
}

variable "kafka_credentials_arn" {
  type        = string
  description = "The arn of the secret containing the kafka credentials. The content dependes on the \"kafka_authentication_type\" var."
  default     = ""
}

variable "kafka_ca_secret_arn" {
  type        = string
  description = "The arn of the secret containing the ca certificate in PEM format"
  default     = ""
}

variable "schema_registry_endpoint" {
  type        = string
  description = "Schema registry endpoint including the protocol (i.e. https://...)."
  default     = ""
}

variable "schema_registry_credentials_arn" {
  type        = string
  description = "Secret containing the username and password to connect to schema registry"
  default     = ""
}

## SQS variables

variable "queue_name" {
  type        = string
  description = "Name of the SQS queue name"
  default     = "consumer_sqs"
  validation {
    condition     = length(var.queue_name) > 0
    error_message = "SQS queue name \"queue_name\" must be non empty."
  }
}

variable "message_retention_seconds" {
  type        = number
  description = "The number of seconds the SQS retains a message. Used for queue and dlq."
  default     = 1209600 # 14 days
}

variable "receive_wait_time_seconds" {
  type        = number
  description = "SQS Long polling configureation."
  default     = 0
}
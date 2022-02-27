variable "function_name" {
  type        = string
  default     = "kafka-consumer"
  description = "Lambda function name"
}

variable "log_group_retention_days" {
  type        = number
  default     = 30
  description = "Cloudwatch log group retention in days"
}

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

variable "kafka_subnet_ids" {
  type        = list(string)
  description = "List of subnets ids to use for the kafka event source"
  default     = []
}

variable "kafka_sg_ids" {
  type        = list(string)
  description = "List of security group id to access kafka"
  default     = []
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
variable "kafka_secret_name" {
  type        = string
  default     = "kafka_credentials"
  description = "Name of the secretsmanager certificate"
}

variable "kafka_username" {
  type        = string
  description = "SASL PLAIN username"
  validation {
    condition     = length(var.kafka_username) > 0
    error_message = "Username must be non-empty."
  }
}

variable "kafka_password" {
  type        = string
  description = "SASL PLAIN username password"
  validation {
    condition     = length(var.kafka_password) > 0
    error_message = "Password must be non-empty."
  }
}

variable "schema_registry_secret_name" {
  type        = string
  default     = "schema_registry_credentials"
  description = "Name of the secretsmanager certificate"
}

variable "schema_registry_username" {
  type        = string
  description = "Schema registry username"
}

variable "schema_registry_password" {
  type        = string
  description = "Schema registry password"
}
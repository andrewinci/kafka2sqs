variable "user_certificate_secret_name" {
  type        = string
  default     = "kafka_user_certificate"
  description = "Name of the secretsmanager certificate"
}

variable "user_certificate" {
  type        = string
  description = "PEM encoded user certificate"
  validation {
    condition     = length(var.user_certificate) > 0
    error_message = "User certificate must be non-empty."
  }
}

variable "private_key" {
  type        = string
  description = "PEM PKCS8 private key"
  validation {
    condition     = length(var.private_key) > 0
    error_message = "Private key must be non-empty."
  }
}

#todo: support
variable "private_key_password" {
  type    = string
  default = ""
}

variable "ca_certificate_secret_name" {
  type        = string
  default     = "kafka_ca_certificate"
  description = "Name of the secretsmanager certificate"
}

variable "ca_certificate" {
  type        = string
  default     = ""
  description = "PEM encoded CA certificate"
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
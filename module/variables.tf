variable "function_name" {
  type    = string
  default = "kafka-consumer"
}

variable "log_group_retention_days" {
  type    = number
  default = 30
}

# todo: support multiple topics
variable "kafka_topic" {
  type = string
}

variable "kafka_batch_size" {
  type    = number
  default = 10
}

# One of: LATEST, TRIM_HORIZON
variable "kafka_starting_position" {
  type    = string
  default = "TRIM_HORIZON"
}

variable "kafka_endpoints" {
  type        = string
  description = "Comma separated kafka endpoints <ip>:<port>"
}

variable "kafka_subnet_ids" {
  type        = list(string)
  description = "List of subnets ids to use for the kafka event source"
}

variable "kafka_sg_id" {
  type        = string
  description = "Security group id to access kafka"
}

/*
  Format for this should be
  {\"certificate\": \"PEM certificate\", \"privateKey\": \"somePrivateKey\", (OPTIONAL) \"privateKeyPassword\": \"somePrivateKeyPassword\"}",
  */
variable "kafka_certificate_secret_arn" {
  type        = string
  description = "arn of the secret containing the client certificate"
}

/*
Format for this should be
{\"certificate\": \"PEM certificate\"}",
*/
variable "kafka_ca_secret_arn" {
  type        = string
  description = "arn of the secret containing the ca certificate in PEM format"
}
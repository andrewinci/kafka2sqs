module "name" {
  source = "github.com/andrewinci/lambda-kafka2sqs/module"
  kafka_topic = "example"
  kafka_endpoints = "kafka1.example.com:9092,kafka2.example.com:9092"
  kafka_subnet_ids = ["subnet1"]
  kafka_sg_id = "arn:...."
  kafka_certificate_secret_arn = "arn:..."
  kafka_ca_secret_arn = "arn:...."
}
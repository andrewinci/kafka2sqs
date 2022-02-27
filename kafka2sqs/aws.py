import boto3
import json


class AWSHelper:
    def __init__(self, queue_url, dlq_url) -> None:
        self.selfsecretsmanager = boto3.client("secretsmanager")
        self.sqs = boto3.client("sqs")
        self.queue_url = queue_url
        self.dlq_url = dlq_url

    def retrieve_secret(self, secret_arn: str):
        response = self.selfsecretsmanager.get_secret_value(SecretId=secret_arn)
        return json.loads(response["SecretString"])

    def send_to_sqs(self, message: dict):
        print("Success", message)
        self.sqs.send_message(QueueUrl=self.queue_url, MessageBody=json.dumps(message))

    def send_to_dlq(self, message: dict):
        print("Failure", message)
        self.sqs.send_message(QueueUrl=self.dlq_url, MessageBody=json.dumps(message))

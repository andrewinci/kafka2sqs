import boto3
import json


class AWSHelper:
    def __init__(self) -> None:
        self.selfsecretsmanager = boto3.client("secretsmanager")

    def retrieve_secret(self, secret_arn: str):
        response = self.selfsecretsmanager.get_secret_value(SecretId=secret_arn)
        return json.loads(response["SecretString"])

    async def send_to_sqs(self, message: str):
        # todo: sqs
        print("Success", message)
        pass

    async def send_to_dlq(self, message: str):
        # todo: sqs
        print("Failure", message)
        pass

import logging
import os
import asyncio

from .serializer import Serializer
from .handler import Handler
from .aws import AWSHelper

# Retrieve env variables
TOPIC_CONFIGURATION = os.environ.get("TOPIC_CONFIGURATION")
SCHEMA_REGISTRY_URL = os.environ.get("SCHEMA_REGISTRY_URL")
SCHEMA_REGISTRY_SECRET_ARN = os.environ.get("SCHEMA_REGISTRY_SECRET_ARN")
SQS_URL = os.environ.get("SQS_URL")
DLQ_URL = os.environ.get("DLQ_URL")

# Build dependencies
aws_helper = AWSHelper(SQS_URL, DLQ_URL)
schema_registry_credentials = (
    aws_helper.retrieve_secret(SCHEMA_REGISTRY_SECRET_ARN)
    if SCHEMA_REGISTRY_SECRET_ARN
    else None
)
serializer = Serializer(SCHEMA_REGISTRY_URL, schema_registry_credentials, logging)
handler = Handler(TOPIC_CONFIGURATION, serializer, aws_helper, logging)

# Lambda handler
def lambda_handler(event, _):
    asyncio.run(handler.handle(event))

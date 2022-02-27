import json
import typing
import os
import asyncio
import boto3
from collections import namedtuple
from .handler import Handler
from schema_registry.serializers import AsyncAvroMessageSerializer
from schema_registry.client import AsyncSchemaRegistryClient

TOPIC_CONFIGURATION = os.environ.get("TOPIC_CONFIGURATION")
SCHEMA_REGISTRY_URL = os.environ.get("SCHEMA_REGISTRY_URL")
SCHEMA_REGISTRY_SECRET_ARN = os.environ.get("SCHEMA_REGISTRY_SECRET_ARN")

SchemaRegistryConfig = namedtuple("SchemaRegistryConfig", "endpoint username password")


def lambda_handler(event, _):
    topic_configs = parse_topic_configuration(TOPIC_CONFIGURATION)
    schema_registry_config = retrieve_schema_registry_configs()
    avro_serializer = (
        None
        if not schema_registry_config
        else build_avro_serializer(schema_registry_config)
    )
    handler = Handler(topic_configs, avro_serializer)
    return asyncio.run(handler.handle(event))


def retrieve_schema_registry_configs() -> typing.Optional[SchemaRegistryConfig]:
    if not SCHEMA_REGISTRY_URL:
        return None
    elif not SCHEMA_REGISTRY_SECRET_ARN:
        return SchemaRegistryConfig(SCHEMA_REGISTRY_URL, None, None)
    else:
        client = boto3.client("secretsmanager")
        response = client.get_secret_value(SecretId=SCHEMA_REGISTRY_SECRET_ARN)
        credentials = json.loads(response["SecretString"])
        return SchemaRegistryConfig(
            SCHEMA_REGISTRY_URL, credentials["username"], credentials["password"]
        )


def build_avro_serializer(
    schema_registry_config: SchemaRegistryConfig,
) -> AsyncAvroMessageSerializer:
    # Configure the schema registry client
    client_configs = {"url": schema_registry_config.endpoint}
    if schema_registry_config.username:
        client_configs["basic.auth.credentials.source"] = "USER_INFO"
        client_configs[
            "basic.auth.user.info"
        ] = f"{ schema_registry_config.username }:{ schema_registry_config.password }"
    schema_registry_client = AsyncSchemaRegistryClient(client_configs)
    return AsyncAvroMessageSerializer(schema_registry_client)


def parse_topic_configuration(config) -> dict:
    """
    Parse a list of maps {"is_avro":true,"topic_name":"test"}
    into a map { "<topic_name>": <is_avro> }
    """
    res = {}
    for c in json.loads(config):
        if res.get(c["topic_name"]):
            raise Exception("Duplicate topic name in configuration")
        res[c["topic_name"]] = c["is_avro"]
    return res

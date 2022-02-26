from collections import namedtuple
import json
import typing
import base64
import os
import asyncio
from schema_registry.serializers import AsyncAvroMessageSerializer
from schema_registry.client import AsyncSchemaRegistryClient

RawRecord = namedtuple("RawRecord", "topic raw_key raw_value timestamp original")
Record = namedtuple("Record", "topic key value timestamp")
SchemaRegistryConfig = namedtuple("SchemaRegistryConfig", "endpoint username password")

TOPIC_CONFIGURATION = os.environ.get("TOPIC_CONFIGURATION")


def lambda_handler(event, _):
    return asyncio.run(Handler(TOPIC_CONFIGURATION).handle(event))


class Handler:
    def __init__(
        self,
        topic_configuration: str,
        schema_registry_config: SchemaRegistryConfig = None,
    ) -> None:
        if topic_configuration is None:
            raise Exception("Unable to init the Handler: Missing topic configuration")
        self.topic_configuration = self._parse_topic_configuration(topic_configuration)
        if schema_registry_config:
            self._configure_schema_registry(schema_registry_config)

    def _configure_schema_registry(self, schema_registry_config: SchemaRegistryConfig):
        # Configure the schema registry client
        client_configs = {"url": schema_registry_config.endpoint}
        if schema_registry_config.username:
            client_configs["basic.auth.credentials.source"] = "USER_INFO"
            client_configs[
                "basic.auth.user.info"
            ] = f"{ schema_registry_config.username }:{ schema_registry_config.password }"
        schema_registry_client = AsyncSchemaRegistryClient(client_configs)
        self.avro_serializer = AsyncAvroMessageSerializer(schema_registry_client)

    def _parse_topic_configuration(self, config) -> dict:
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

    async def handle(self, event):
        """
        Main lambda handler
        """
        parsed = []
        failed = []
        for r in self.extract_records(event):
            try:
                parsed.append(await self.deserialize_record(r))
            except Exception as e:
                print(f"Unable to deserialize the record: {e}")
                failed.append(r.original)
        # todo: send to sqs and dlq
        print("Parsed", parsed)
        print("Failed", failed)
        return json.dumps([r._asdict() for r in parsed])

    def extract_records(self, event) -> typing.List[RawRecord]:
        """
        Extract the raw records from the event triggered by the lambda
        runtime
        """
        return [
            RawRecord(r["topic"], r["key"], r["value"], r["timestamp"], r)
            for v in event["records"].values()
            for r in v
        ]

    async def deserialize_record(self, record: RawRecord) -> Record:
        """
        Deserialize the key and the value of the record coming
        from the kafka topic
        """
        is_avro = self.topic_configuration.get(record.topic)
        if is_avro is None:
            raise Exception(f"Missing configuration for topic {record.topic}")
        # assumption: the key is always string
        key = base64.standard_b64decode(record.raw_key).decode("UTF-8")
        bin_value: bytes = base64.standard_b64decode(record.raw_value)
        if not is_avro:
            return Record(
                record.topic, key, bin_value.decode("UTF-8"), record.timestamp
            )
        elif self.avro_serializer:
            value = await self.avro_serializer.decode_message(bin_value)
            return Record(record.topic, key, json.loads(value), record.timestamp)
        else:
            raise Exception(
                "Unable to deserialize avro. Missing schema registry configuration"
            )

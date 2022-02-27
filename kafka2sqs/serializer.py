import base64
import logging
import typing
from schema_registry.serializers import AsyncAvroMessageSerializer
from schema_registry.client import AsyncSchemaRegistryClient

from kafka2sqs.aws import AWSHelper

KEY_FIELD_NAME = "key"
PARSED_KEY_FIELD_NAME = "parsed_key"
VALUE_FIELD_NAME = "value"
PARSED_VALUE_FIELD_NAME = "parsed_value"


class Serializer:
    def __init__(
        self,
        schema_registry_endpoint: str,
        schema_registry_credentials: dict,
        logger: logging,
    ) -> None:
        avro_serializer = self._build_avro_serializer(
            schema_registry_endpoint, schema_registry_credentials
        )
        if avro_serializer is None:
            logger.warning("missing avro serialization configuration")
        self.avro_serializer = avro_serializer

    async def deserialize(self, record: dict, is_avro: bool) -> None:
        """
        Deserialize the key and the value of the record coming
        from the kafka topic and attach it to the record itself.
        """
        if not is_avro:
            self._deserialize_string(record)
        elif self.avro_serializer:
            await self._deserialize_avro(record)
        else:
            raise Exception(
                "Unable to deserialize avro. Missing schema registry configuration"
            )
        return record

    def _deserialize_string(self, record: dict) -> None:
        """
        Add the parsed string fields to the original record
        """
        record[PARSED_KEY_FIELD_NAME] = base64.standard_b64decode(
            record[KEY_FIELD_NAME]
        ).decode("UTF-8")
        record[PARSED_VALUE_FIELD_NAME] = base64.standard_b64decode(
            record[VALUE_FIELD_NAME]
        ).decode("UTF-8")

    async def _deserialize_avro(self, record: dict) -> None:
        """
        Add the parsed avro fields to the original record
        """
        record[PARSED_KEY_FIELD_NAME] = base64.standard_b64decode(
            record[KEY_FIELD_NAME]
        ).decode("UTF-8")
        bin_value = base64.standard_b64decode(record[VALUE_FIELD_NAME])
        record[PARSED_VALUE_FIELD_NAME] = await self.avro_serializer.decode_message(
            bin_value
        )

    def _build_avro_serializer(
        self, schema_registry_endpoint: str, credentials: dict
    ) -> AsyncAvroMessageSerializer:
        """
        Build an avro serializer that use the schema registry
        to retrieve the schema.
        """
        if not schema_registry_endpoint:
            return None
        elif not credentials:
            schema_registry_client = AsyncSchemaRegistryClient(
                {"url": schema_registry_endpoint}
            )
            return AsyncAvroMessageSerializer(schema_registry_client)
        else:
            client_configs = {
                "url": schema_registry_endpoint,
                "basic.auth.credentials.source": "USER_INFO",
                "basic.auth.user.info": f'{ credentials["username"] }:{ credentials["password"] }',
            }
            schema_registry_client = AsyncSchemaRegistryClient(client_configs)
            return AsyncAvroMessageSerializer(schema_registry_client)

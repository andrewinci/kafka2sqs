import base64
import logging
import typing
import logging
import typing
import io
from fastavro import schemaless_reader, schemaless_writer, json_writer
from schema_registry.client import AsyncSchemaRegistryClient, utils
from schema_registry.client.schema import BaseSchema
from schema_registry.serializers import AsyncMessageSerializer

KEY_FIELD_NAME = "key"
PARSED_KEY_FIELD_NAME = "parsed_key"
VALUE_FIELD_NAME = "value"
PARSED_VALUE_FIELD_NAME = "parsed_value"


class AsyncAvroJsonMessageSerializer(AsyncMessageSerializer):
    @property
    def _serializer_schema_type(self) -> str:
        return utils.AVRO_SCHEMA_TYPE

    def _get_encoder_func(self, schema: BaseSchema) -> typing.Callable:
        return lambda record, fp: schemaless_writer(fp, schema.schema, record)  # type: ignore

    def _decoder_func(self, payload, schema):
        record = schemaless_reader(
            payload, schema, self.reader_schema, self.return_record_name
        )
        out = io.StringIO()
        json_writer(out, schema, [record])
        return out.getvalue()

    def _get_decoder_func(self, payload, writer_schema: BaseSchema) -> typing.Callable:
        return lambda payload: self._decoder_func(payload, writer_schema.schema)


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
    ) -> AsyncAvroJsonMessageSerializer:
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
            return AsyncAvroJsonMessageSerializer(schema_registry_client)
        else:
            client_configs = {
                "url": schema_registry_endpoint,
                "basic.auth.credentials.source": "USER_INFO",
                "basic.auth.user.info": f'{ credentials["username"] }:{ credentials["password"] }',
            }
            schema_registry_client = AsyncSchemaRegistryClient(client_configs)
            return AsyncAvroJsonMessageSerializer(schema_registry_client)

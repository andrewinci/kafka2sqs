import json
import typing
import base64
from collections import namedtuple
from schema_registry.serializers import AsyncAvroMessageSerializer
from schema_registry.client import AsyncSchemaRegistryClient

RawRecord = namedtuple("RawRecord", "topic raw_key raw_value timestamp original")
Record = namedtuple("Record", "topic key value timestamp")


class Handler:
    def __init__(
        self,
        topic_configuration: dict,
        avro_serializer: AsyncAvroMessageSerializer = None,
    ) -> None:
        if topic_configuration is None:
            raise Exception("Unable to init the Handler: Missing topic configuration")
        self.topic_configuration = topic_configuration
        if avro_serializer:
            self.avro_serializer = avro_serializer
        else:
            print(
                "warning: Missing schema registry configuration. Unable to deserialize avro messages"
            )

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
            return Record(record.topic, key, json.dumps(value), record.timestamp)
        else:
            raise Exception(
                "Unable to deserialize avro. Missing schema registry configuration"
            )

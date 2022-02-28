import json
import logging
from signal import raise_signal

from .aws import AWSHelper
from .serializer import PARSED_KEY_FIELD_NAME, PARSED_VALUE_FIELD_NAME, Serializer


class Handler:
    def __init__(
        self,
        raw_topic_configuration: str,
        serializer: Serializer,
        aws_helper: AWSHelper,
        log: logging,
    ) -> None:
        self.topic_configuration = self._parse_topic_config(raw_topic_configuration)
        self.serializer = serializer
        self.aws_helper = aws_helper
        self.log = log

    def _parse_topic_config(self, config: str) -> dict:
        """
        Parse a list of maps {"is_avro":true,"topic_name":"test"}
        into a map { "<topic_name>": <is_avro> }
        """
        res = {}
        for c in json.loads(config):
            if res.get(c["topic_name"]):
                raise Exception("Duplicate topic name in configuration")
            res[c["topic_name"]] = c["is_avro"]
        if len(res) == 0:
            raise Exception("Empty topic configuration.")
        return res

    async def handle(self, event):
        """
        Main lambda handler
        """
        kafka_records = [r for v in event["records"].values() for r in v]
        # Try to parse each record depending on the format
        # defined in the config.
        for record in kafka_records:
            try:
                is_avro = self.topic_configuration.get(record["topic"])
                if is_avro is None:
                    raise Exception(
                        f"Missing configuration for topic {record['topic']}"
                    )
                parsed = await self.serializer.deserialize(record, is_avro)
                self.aws_helper.send_to_sqs(parsed)
            except Exception as e:
                self.log.warning(f"Unable to process the record {e}")
                # add exception to the record
                record["process_exception"] = str(e)
                record.pop(PARSED_KEY_FIELD_NAME, None)
                record.pop(PARSED_VALUE_FIELD_NAME, None)
                self.aws_helper.send_to_dlq(record)

from collections import namedtuple
import json
import typing
import base64
import os

RawRecord = namedtuple("RawRecord", "topic raw_key raw_value timestamp original")
Record = namedtuple("Record", "topic key value timestamp")
TOPIC_CONFIGURATION = os.environ.get("TOPIC_CONFIGURATION")


def lambda_handler(event, _):
    return Handler(TOPIC_CONFIGURATION).handle(event)


class Handler:
    def __init__(self, topic_configuration: str) -> None:
        if topic_configuration is None:
            raise Exception("Unable to init the Handler: Missing topic configuration")
        self.topic_configuration = self.parse_topic_configuration(topic_configuration)

    def parse_topic_configuration(self, config):
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

    def handle(self, event):
        """
        Main lambda handler
        """
        parsed = []
        failed = []
        for r in self.extract_records(event):
            try:
                parsed.append(self.deserialize_record(r))
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

    def deserialize_record(self, record: RawRecord) -> Record:
        """
        Deserialize the key and the value of the record coming
        from the kafka topic
        """
        is_avro = self.topic_configuration.get(record.topic)
        if is_avro is None:
            raise Exception(f"Missing configuration for topic {record.topic}")
        if is_avro:
            raise Exception("Avro is not supported yet")
        # assumption: the key is always string
        key = base64.standard_b64decode(record.raw_key).decode("UTF-8")
        value = base64.standard_b64decode(record.raw_value).decode("UTF-8")
        return Record(record.topic, key, value, record.timestamp)

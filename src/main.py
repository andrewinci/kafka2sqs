from collections import namedtuple
from email.mime import base
import json
import typing
import base64

RawRecord = namedtuple("RawRecord", "topic raw_key raw_value timestamp")
Record = namedtuple("Record", "topic key value timestamp")


def lambda_handler(event, _):
    records = [deserialize_record(r) for r in extract_records(event)]
    return json.dumps([r._asdict() for r in records])


def extract_records(event) -> typing.List[RawRecord]:
    return [
        RawRecord(r["topic"], r["key"], r["value"], r["timestamp"])
        for v in event["records"].values()
        for r in v
    ]


def deserialize_record(record: RawRecord) -> Record:
    # assumption: the key is always string
    key = base64.standard_b64decode(record.raw_key).decode("UTF-8")
    value = base64.standard_b64decode(record.raw_value).decode("UTF-8")
    return Record(record.topic, key, value, record.timestamp)

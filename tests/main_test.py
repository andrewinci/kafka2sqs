from kafka2sqs.main import parse_topic_configuration
from kafka2sqs.handler import Handler, RawRecord
import pytest


def test_parse_topic_configuration_happy_path():
    raw_test_config = """[{"is_avro":true,"topic_name":"test"},{"is_avro":false,"topic_name":"test-2"}]"""
    res = parse_topic_configuration(raw_test_config)
    assert res == {"test": True, "test-2": False}


def test_parse_topic_configuration_raise_if_duplicate_topic():
    raw_test_config = """[{"is_avro":true,"topic_name":"test"},{"is_avro":false,"topic_name":"test"}]"""
    try:
        parse_topic_configuration(raw_test_config)
    except:
        return
    assert False


@pytest.mark.asyncio
async def test_handler():
    sut = Handler({})
    result = await sut.handle(event)
    assert result


def test_extract_records():
    sut = Handler({})
    records = sut.extract_records(event)
    assert len(records) == 2
    assert records[0].topic == "test"
    assert records[1].timestamp == 1645867668847


@pytest.mark.asyncio
async def test_decode_string_record():
    rawRecord = RawRecord("topic", "dGVzdC1rZXk=", "dGVzdC12YWx1ZQ==", 123, {})
    sut = Handler({"topic": False})
    record = await sut.deserialize_record(rawRecord)
    assert record.key == "test-key"
    assert record.value == "test-value"


event = {
    "eventSource": "SelfManagedKafka",
    "bootstrapServers": "bootstrap-server:9092",
    "records": {
        "test-0": [
            {
                "topic": "test",
                "partition": 0,
                "offset": 8,
                "timestamp": 1645867668847,
                "timestampType": "CREATE_TIME",
                "key": "dGVzdC1rZXk=",
                "value": "dGVzdC12YWx1ZQ==",
                "headers": [],
            }
        ],
        "test-1": [
            {
                "topic": "test",
                "partition": 1,
                "offset": 2,
                "timestamp": 1645867668847,
                "timestampType": "CREATE_TIME",
                "key": "dGVzdC1rZXk=",
                "value": "dGVzdC12YWx1ZQ==",
                "headers": [],
            }
        ],
    },
}

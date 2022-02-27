import asyncio
import logging
from signal import raise_signal
from pytest import fail
from kafka2sqs.handler import Handler
import pytest
from unittest.mock import Mock


def test_invalid_topic_config():
    try:
        Handler("", None, None, logging)
        fail("Handler init should raise an exception")
    except:
        pass


def test_empty_topic_config():
    try:
        Handler("[]", None, None, logging)
        fail("Handler init should raise an exception")
    except:
        pass


def test_duplicated_topic_in_configuration():
    try:
        raw_test_config = """[{"is_avro":true,"topic_name":"test"},{"is_avro":false,"topic_name":"test"}]"""
        Handler(raw_test_config, None, None, logging)
        fail("Handler init should raise an exception")
    except:
        pass


@pytest.mark.asyncio
async def test_happy_path():
    raw_test_config = """[{"is_avro":false,"topic_name":"test"}]"""
    sqs = []

    class MockSerializer:
        async def deserialize(self, record: dict, is_avro: bool):
            record["deserialized"] = True
            return record

    class MockAwsHelper:
        async def send_to_sqs(self, record):
            sqs.append(record)

    sut = Handler(raw_test_config, MockSerializer(), MockAwsHelper(), logging)
    # Act
    await sut.handle(event)
    # Assert
    assert len(sqs) == 2
    assert len([r for r in sqs if r["deserialized"] == True]) == 2


@pytest.mark.asyncio
async def test_serialization_error_path():
    raw_test_config = """[{"is_avro":false,"topic_name":"test"}]"""
    dlq = []

    class MockSerializer:
        async def deserialize(self, record: dict, is_avro: bool):
            raise Exception("Serialization error")

    class MockAwsHelper:
        async def send_to_dlq(self, record):
            dlq.append(record)

    sut = Handler(raw_test_config, MockSerializer(), MockAwsHelper(), logging)
    # Act
    await sut.handle(event)
    # Assert
    assert len(dlq) == 2


@pytest.mark.asyncio
async def test_use_dlq_for_uncofigured_topics_path():
    raw_test_config = """[{"is_avro":false,"topic_name":"un-configured"}]"""
    dlq = []

    class MockSerializer:
        async def deserialize(self, record: dict, is_avro: bool):
            raise Exception("Serialization error")

    class MockAwsHelper:
        async def send_to_dlq(self, record):
            dlq.append(record)

    sut = Handler(raw_test_config, MockSerializer(), MockAwsHelper(), logging)
    # Act
    await sut.handle(event)
    # Assert
    assert len(dlq) == 2


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

import logging
from unittest.mock import Mock
import os
import pytest
from kafka2sqs.serializer import Serializer


def test_warn_if_missing_avro_config():
    mockLog = Mock()
    # Act
    Serializer("", None, mockLog)
    # Arrange
    mockLog.warning.assert_called()


@pytest.mark.asyncio
async def test_decode_string_happy_path():
    sut = Serializer("", None, logging)
    record = {
        "key": "dGVzdC1rZXk=",
        "value": "dGVzdC12YWx1ZQ==",
    }
    await sut.deserialize(record, False)
    assert record == {
        "key": "dGVzdC1rZXk=",
        "value": "dGVzdC12YWx1ZQ==",
        "parsed_key": "test-key",
        "parsed_value": "test-value",
    }


# Need schema registry configs in env to run this
# @pytest.mark.asyncio
# async def test_decode_avro_happy_path():
#     endpoint = os.environ.get("SCHEMA_REGISTRY_URL")
#     credentials = {
#         "username": os.environ.get("SCHEMA_REGISTRY_USERNAME"),
#         "password": os.environ.get("SCHEMA_REGISTRY_PASSWORD"),
#     }
#     sut = Serializer(endpoint, credentials, logging)
#     record = {
#         "key": "dGVzdC1rZXk=",
#         "value": "AAABhrwIbmFtZfYB",
#     }
#     await sut.deserialize(record, True)
#     assert record == {
#         "key": "dGVzdC1rZXk=",
#         "value": "AAABhrwIbmFtZfYB",
#         "parsed_key": "test-key",
#         "parsed_value": {"Age": 123, "Name": "name"},
#     }

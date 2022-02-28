import pytest
import base64
from kafka2sqs.serializer import AsyncAvroJsonMessageSerializer
from schema_registry.client.schema import AvroSchema


@pytest.mark.asyncio
async def test_custom_serializer_happy_path():
    # Arrange
    bin_message = base64.standard_b64decode("AAABhrwIbmFtZfYB")

    class MockSchemaRegistry:
        async def get_by_id(self, _):
            return AvroSchema(schema)

    sut = AsyncAvroJsonMessageSerializer(MockSchemaRegistry())
    # Act
    res = await sut.decode_message(bin_message)
    # Assert
    assert res == {"Age": 123, "Name": "name"}


schema = """{"type":"record","name":"Employee","namespace":"Tutorialspoint","fields":[{"name":"Name","type":"string"},{"name":"Age","type":"int"}]}"""

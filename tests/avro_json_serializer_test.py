import pytest
import base64
from kafka2sqs.serializer import AsyncAvroJsonMessageSerializer
from schema_registry.client.schema import AvroSchema


@pytest.mark.asyncio
async def test_custom_serializer_happy_path():
    # Arrange
    bin_message = base64.standard_b64decode("AAABhrwIbmFtZfYB")
    schema = """{"type":"record","name":"Employee","namespace":"Tutorialspoint","fields":[{"name":"Name","type":"string"},{"name":"Age","type":"int"}]}"""

    class MockSchemaRegistry:
        async def get_by_id(self, _):
            return AvroSchema(schema)

    sut = AsyncAvroJsonMessageSerializer(MockSchemaRegistry())
    # Act
    res = await sut.decode_message(bin_message)
    # Assert
    assert res == '{"Name": "name", "Age": 123}'


@pytest.mark.asyncio
async def test_custom_serializer_happy_path_2():
    # Arrange
    bin_message = base64.standard_b64decode("AAABhr4ACG5hbWX2AYIFxpkn")
    schema = """{"type":"record","name":"Employee","namespace":"Tutorialspoint","fields":[{"name":"Name","type":["string","int"]},{"name":"Age","type":"int"},{"name":"Count","type":"int"},{"name":"Time","type":{"type":"int","logicalType":"date"}}]}"""

    class MockSchemaRegistry:
        async def get_by_id(self, _):
            return AvroSchema(schema)

    sut = AsyncAvroJsonMessageSerializer(MockSchemaRegistry())
    # Act
    res = await sut.decode_message(bin_message)
    # Assert
    assert (
        res == '{"Name": {"string": "name"}, "Age": 123, "Count": 321, "Time": 321123}'
    )

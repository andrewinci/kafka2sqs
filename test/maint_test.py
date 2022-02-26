from src.main import RawRecord, deserialize_record, extract_records, lambda_handler

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


def test_handler():
    result = lambda_handler(event, None)
    assert result


def test_extract_records():
    records = extract_records(event)
    assert len(records) == 2
    assert records[0].topic == "test"
    assert records[1].timestamp == 1645867668847


def test_decode_string_record():
    rawRecord = RawRecord("topic", "dGVzdC1rZXk=", "dGVzdC12YWx1ZQ==", 123)
    record = deserialize_record(rawRecord)
    assert record.key == "test-key"
    assert record.value == "test-value"

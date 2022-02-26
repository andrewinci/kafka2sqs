from src.main import extract_records

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
                "value": "AAABhrwIbmFtZfYB",
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
                "value": "AAABhrwIbmFtZfYB",
                "headers": [],
            }
        ],
    },
}


def test_extract_records():
    records = extract_records(event)
    assert len(records) == 2
    assert records[0]["topic"] == "test"
    assert records[1]["partition"] == 1

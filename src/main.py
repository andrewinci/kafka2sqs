def lambda_handler(event, context):
    records = extract_records(event)
    print(records)
    print(context)


def extract_records(event):
    return [r for v in event["records"].values() for r in v]

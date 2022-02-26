import json
from datetime import datetime


def lambda_handler(event, context):
    event_received_at = datetime.utcnow()
    print("Event received at: {}".format(event_received_at))
    print("Received event:", json.loads(event))
    print("success")

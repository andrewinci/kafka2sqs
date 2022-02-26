# Lambda Kafka2SQS

Terraform module that creates a lambda triggered by kafka topics.
The lambda deserialize any received message and publish them into an SQS queue.

## Requirements
- python3
- [tfswitch](https://github.com/warrensbox/terraform-switcher)

## Dev

Package the lambda with
```bash
make
```

Init the python virtualenv with
```bash
make venv && source kafka2sqs/bin/activate
```

Lint the code with
```bash
make lint
```


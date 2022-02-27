TF=terraform
PYTHON=python3
VENV=.kafka2sqs
BUILD_VENV=.build_venv

LAMBDA_ZIP=lambda.zip
TF_ZIP=module.zip
PY_SRC=kafka2sqs
PY_TESTS=tests

.PHONY: clean test

$(TF_ZIP): $(LAMBDA_ZIP) module/**
	cp $(LAMBDA_ZIP) module/lambda/
	cd module && zip -r ../$(TF_ZIP) *

$(LAMBDA_ZIP): requirements.txt $(PY_SRC)/* $(BUILD_VENV)/bin/activate
	@echo "Package dependencies"
	cd $(BUILD_VENV)/lib/python*/site-packages; \
	rm -rf pip* setup* pkg_* _distutils_hack; \
	zip -r ../../../../$(LAMBDA_ZIP) .
	@echo "Add the handler"
	zip -r $(LAMBDA_ZIP) $(PY_SRC)

lint: venv
	$(VENV)/bin/python -m black $(PY_SRC)/ $(PY_TESTS)/
	$(TF) fmt -recursive module
	$(TF) fmt -recursive examples

check: venv test
	cd module; \
	$(TF) init; \
	$(TF) fmt -recursive -check; \
	$(TF) validate
	$(TF) fmt -recursive -check examples
	$(VENV)/bin/python -m black --check $(PY_SRC)

test: venv
	$(VENV)/bin/python -m pytest tests --asyncio-mode=strict

$(BUILD_VENV)/bin/activate: requirements.txt
	$(PYTHON) -m venv $(BUILD_VENV); \
	$(BUILD_VENV)/bin/pip install -r requirements.txt

venv: $(VENV)/bin/activate

$(VENV)/bin/activate: requirements.txt requirements.dev.txt
	$(PYTHON) -m venv $(VENV)
	$(VENV)/bin/pip install -r requirements.dev.txt
	$(VENV)/bin/pip install -r requirements.txt

clean: venv
	@echo Remove all generated zip files
	find . | grep .zip | xargs rm -rf
	@echo Remove python cache files
	$(VENV)/bin/python -m pyclean kafka2sqs tests
	@echo Remove build venv
	rm -rf $(BUILD_VENV)
TF=terraform
VENV=kafka2sqs
PYTHON = $(VENV)/bin/python3
PIP = $(VENV)/bin/pip
BUILD_VENV=build_venv
LAMBDA_ZIP=lambda.zip
TF_ZIP=module.zip

.PHONY: clean test

$(TF_ZIP): module/lambda/$(LAMBDA_ZIP) module/*
	rm -rf $(TF_ZIP)
	cd module && zip -r ../$(TF_ZIP) *

module/lambda/$(LAMBDA_ZIP): requirements.txt src/*
	@echo "Cleanup previous artifacts if any"
	rm -rf $(BUILD_VENV)
	rm -rf  module/lambda/$(LAMBDA_ZIP)
	@echo "Init prod venv"
	python3 -m venv $(BUILD_VENV); \
	$(BUILD_VENV)/bin/pip install -r requirements.txt
	@echo "Package dependencies"
	cd $(BUILD_VENV)/lib/python*/site-packages; \
	rm -rf pip* setup* pkg_* _distutils_hack; \
	zip -r ../../../../$(LAMBDA_ZIP) .
	@echo "Remove pycache"
	cd src && rm -rf __pycache__
	@echo "Add the handler"
	cd src && zip -g ../$(LAMBDA_ZIP) *
	@echo "Move the lambda into the tf module"
	mv $(LAMBDA_ZIP) module/lambda/

lint: venv
	$(PYTHON) -m black src/ test/
	$(TF) fmt -recursive module
	$(TF) fmt -recursive examples

venv: $(VENV)/bin/activate
	@echo "-----\nRun: \n source $(VENV)/bin/activate"

$(VENV)/bin/activate: requirements.txt requirements.dev.txt
	python3 -m venv $(VENV)
	$(PIP) install -r requirements.dev.txt
	$(PIP) install -r requirements.txt

check: venv test
	cd module; \
	$(TF) init; \
	$(TF) fmt -recursive -check; \
	$(TF) validate
	$(TF) fmt -recursive -check examples
	$(PYTHON) -m black --check src/

test:
	$(PYTHON) -m pytest test --asyncio-mode=strict

clean:
	rm -rf $(VENV) \
		$(BUILD_VENV) \
		module/lambda/$(LAMBDA_ZIP) \
		$(TF_ZIP)
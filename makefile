TF=terraform
VENV=.kafka2sqs
PYTHON = $(VENV)/bin/python3
PIP = $(VENV)/bin/pip
BUILD_VENV=.build_venv
LAMBDA_ZIP=lambda.zip
TF_ZIP=module.zip
SRC=kafka2sqs

.PHONY: clean test

$(TF_ZIP): module/lambda/$(LAMBDA_ZIP) module/*
	rm -rf $(TF_ZIP)
	cd module && zip -r ../$(TF_ZIP) *

module/lambda/$(LAMBDA_ZIP): requirements.txt $(SRC)/*
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
	cd $(SRC) && rm -rf __pycache__
	@echo "Add the handler"
	zip -r $(LAMBDA_ZIP) $(SRC)
	@echo "Move the lambda into the tf module"
	mv $(LAMBDA_ZIP) module/lambda/

lint: venv
	$(PYTHON) -m black $(SRC)/ test/
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
	$(PYTHON) -m black --check $(SRC)/

test:
	$(PYTHON) -m pytest tests --asyncio-mode=strict

clean:
	@echo Remove all generated zip files
	find . | grep .zip | xargs rm -rf
	@echo Remove python cache files
	python -m pyclean kafka2sqs tests
	@echo Remove build venv
	rm -rf $(BUILD_VENV)
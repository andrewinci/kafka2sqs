TF=terraform
VENV=kafka2sqs
PYTHON = $(VENV)/bin/python3
PIP = $(VENV)/bin/pip
BUILD_VENV=build_venv
LAMBDA_ZIP=lambda.zip
TF_ZIP=module.zip

.PHONY: clean

$(TF_ZIP): $(LAMBDA_ZIP) module/*
	rm -rf $(TF_ZIP)
	cd module && zip -r ../$(TF_ZIP) .
	zip -g $(TF_ZIP) $(LAMBDA_ZIP)

$(LAMBDA_ZIP): requirements.txt src/*
	rm -rf lambda.zip
	python3 -m venv $(BUILD_VENV); \
	$(BUILD_VENV)/bin/pip install -r requirements.txt
	cd $(BUILD_VENV)/lib/python*/site-packages; \
	zip -r ../../../../$(LAMBDA_ZIP) .
	cd src && zip -g ../$(LAMBDA_ZIP) *
	rm -rf $(BUILD_VENV)

lint: venv
	$(PYTHON) -m black src/
	$(TF) fmt -recursive module
	$(TF) fmt -recursive examples

venv: $(VENV)/bin/activate
	@echo "-----\nRun: \n source $(VENV)/bin/activate"

$(VENV)/bin/activate: requirements.txt requirements.dev.txt
	python3 -m venv $(VENV)
	$(PIP) install -r requirements.dev.txt
	$(PIP) install -r requirements.txt

check: venv
	$(TF) fmt -recursive -check module
	$(TF) fmt -recursive -check examples
	$(PYTHON) -m black --check src/

clean:
	rm -rf $(VENV)
	rm -rf $(BUILD_VENV)
	rm -rf $(LAMBDA_ZIP)
	rm -rf $(TF_ZIP)
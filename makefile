TF=terraform
VENV=kafka2sqs
PYTHON = $(VENV)/bin/python3
PIP = $(VENV)/bin/pip
BUILD_VENV=build_venv
LAMBDA_ZIP=lambda.zip
TF_ZIP=module.zip

.PHONY: clean

$(TF_ZIP): module/$(LAMBDA_ZIP) module/*
	rm -rf $(TF_ZIP)
	cd module && zip -r ../$(TF_ZIP) *.tf
	cd module && zip -r ../$(TF_ZIP) *.zip

module/$(LAMBDA_ZIP): requirements.txt src/*
	@echo "Cleanup previous artifacts if any"
	rm -rf $(BUILD_VENV)
	rm -rf  module/lambda.zip
	@echo "Init prod venv"
	python3 -m venv $(BUILD_VENV); \
	$(BUILD_VENV)/bin/pip install -r requirements.txt
	@echo "Package dependencies"
	cd $(BUILD_VENV)/lib/python*/site-packages; \
	rm -rf pip* setup* pkg_* _distutils_hack; \
	zip -r ../../../../$(LAMBDA_ZIP) .
	@echo "Add the handler"
	cd src && zip -g ../$(LAMBDA_ZIP) *
	@echo "Move the lambda into the tf module"
	mv $(LAMBDA_ZIP) module/

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
	cd module; \
	$(TF) init; \
	$(TF) fmt -recursive -check; \
	$(TF) validate
	$(TF) fmt -recursive -check examples
	$(PYTHON) -m black --check src/

clean:
	rm -rf $(VENV) \
		$(BUILD_VENV) \
		module/$(LAMBDA_ZIP) \
		$(TF_ZIP) \
		module/.terraform \
		module/.terraform.lock.hcl
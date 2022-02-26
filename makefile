TF=terraform
VENV=kafka2sqs
PYTHON = $(VENV)/bin/python3
PIP = $(VENV)/bin/pip
BUILD_VENV=build_venv
ZIP_NAME=lambda.zip

.PHONY: clean

$(ZIP_NAME): requirements.txt src/*
	rm -rf lambda.zip
	python3 -m venv $(BUILD_VENV); \
	$(BUILD_VENV)/bin/pip install -r requirements.txt
	cd $(BUILD_VENV)/lib/python*/site-packages; \
	zip -r ../../../../$(ZIP_NAME) .
	cd src && zip -g ../$(ZIP_NAME) *
	rm -rf $(BUILD_VENV)

lint: $(VENV)/bin/activate
	$(PYTHON) -m black src/
	$(TF) fmt -recursive module

$(VENV)/bin/activate: requirements.txt requirements.dev.txt
	python3 -m venv $(VENV)
	$(PIP) install -r requirements.dev.txt
	$(PIP) install -r requirements.txt

venv: $(VENV)/bin/activate
	@echo "-----\nRun: \n source $(VENV)/bin/activate"
clean:
	rm -rf $(VENV)
	rm -rf $(BUILD_VENV)
	rm -rf $(ZIP_NAME)
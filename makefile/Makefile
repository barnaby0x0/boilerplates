.PHONY: run setup clean build help

# Variables
PYTHON := python
VENV := .venv
SRC_DIR := src/backup_selector
OUTPUT_NAME := backup-selector
DIST_DIR := dist

%:
	@: # Do nothing here

CMD_ARGS := $(filter-out run setup clean, $(MAKECMDGOALS))

$(CMD_ARGS):
	@:

help: ## Display this help
	@echo "Commandes disponibles :"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

run:  ## Run in develop version
	@PYTHONPATH=src .venv/bin/python -m backup_selector $(CMD_ARGS)

install: ## Install develop version
	$(PYTHON) -m pip install -e .

setup: .venv/bin/python ## Setup develop environment
	.venv/bin/python -m pip install --upgrade pip
	.venv/bin/pip install -r requirements.txt 

.venv/bin/python:
	python -m venv .venv

clean: ## Clean .venv
	rm -rf .venv

build: ## Compile bin with Nuitka
	@echo "🧹 Nettoyage..."
	rm -rf $(DIST_DIR)/ build/ *.spec __pycache__ 2>/dev/null || true

	@echo "🚀 Compilation avec Nuitka..."
	PYTHONPATH=src $(PYTHON) -m nuitka \
		--standalone \
		--onefile \
		--remove-output \
		--output-dir=$(DIST_DIR) \
		--output-filename=$(OUTPUT_NAME) \
		--product-name="Backup Selector" \
		--product-version="0.1.0" \
		--include-package=backup_selector \
		--include-package-data=backup_selector \
		--include-package=rich \
		--include-package-data=rich \
		--follow-imports \
		--nofollow-import-to=*.test,*.tests,*.pytest \
		--enable-plugin=anti-bloat \
		$(SRC_DIR)/__main__.py

	@echo "✅ Build terminé !"
	@echo "📍 Exécutable → $(DIST_DIR)/$(OUTPUT_NAME)"
.PHONY: build help

# Variables
PWD := $(CURDIR)
KANIKO_VERSION := v1.26.4
IMG_NAME := $(IMG_NAME)
ifndef IMG_NAME
$(error IMG_NAME undefined. Usage: make build IMG_NAME=<img_name>)
endif
IMG_TAG ?= 0.0.1

help: ## Display this help
	@echo "Commandes disponibles :"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'


build: ## Compile docker image using kaniko
	@docker run --rm \
		-v "$(PWD)":/workspace \
		martizih/kaniko:$(KANIKO_VERSION) \
		--context=/workspace \
		--dockerfile=/workspace/Dockerfile \
		--tar-path=/workspace/$(IMG_NAME).tar \
		--destination=$(IMG_NAME):$(IMG_TAG) \
		--no-push


# Variables

.PHONY: help build_all build_base terraform_plan terraform_apply terraform_destroy clean

# Help target (default)
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build_all: build_base terraform_apply

# make build_base VARS=./(pve1|pve2).pkrvars.hcl
VARS ?= ./variables.auto.pkrvars.hcl
TERRAFORM_VARS = 

build_base: ## Build the template using packer
	export PACKER_LOG_PATH="./packer.log" && export PACKER_LOG=10 && packer build -var-file $(VARS) ubuntu-server-focal.pkr.hcl

deploy_vms: ## terraform apply command for vms
	@(cd terraform/vms; terraform apply -auto-approve -var-file $(TERRAFORM_VARS))

destroy_vms: ## terraform destroy command for vms
	@(cd terraform/vms; terraform destroy -auto-approve)

deploy_containers: ## terraform apply command for containers
	@(cd terraform/containers; terraform apply -auto-approve -var-file $(TERRAFORM_VARS))

destroy_containers: ## terraform destroy command for containers
	@(cd terraform/containers; terraform destroy -auto-approve)	

deploy_networks: ## terraform apply command for networks
	@(cd terraform/vms; terraform apply -auto-approve)

destroy_networks: ## terraform destroy command for networks
	@(cd terraform/vms; terraform destroy -auto-approve)

clean: terraform_destroy ## destroy terraform and the packer template
	@echo "Clean up (terraform + packer template)"
	@ssh root@192.168.1.99 qm destroy 190

makefile.PHONY: plan apply

load_env:
	@./load_vault_secrets.sh

plan: load_env
	terraform init -upgrade
	terraform plan -out=tfplan

apply:
	terraform apply tfplan
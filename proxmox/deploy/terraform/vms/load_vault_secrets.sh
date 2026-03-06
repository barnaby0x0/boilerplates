#!/usr/bin/env bash

export VAULT_ADDR="$(pass vault/lab/VAULT_ADDR)"; vault login $(pass vault/lab/VAULT_ROOT_TOKEN) > /dev/null
while IFS=':' read -r e k v; do eval "export $e=\"\$(vault kv get -field=$k $v)\""; done < .env

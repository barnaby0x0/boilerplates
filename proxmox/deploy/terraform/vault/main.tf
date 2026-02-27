terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.7.0"
    }
  }
}

provider "vault" {
  address = "http://10.0.0.112:8200"
  # token   = var.vault_token

  auth_login {
    path = "auth/approle/login"
    parameters = {
      role_id   = var.vault_role_id
      secret_id = var.vault_secret_id
    }
  }
}

data "vault_generic_secret" "registry_auth" {
  path = "secret/terraform/test"
}

resource "local_file" "credentials" {
  filename = "${path.module}/credentials.json"
  content  = <<EOF
${data.vault_generic_secret.registry_auth.data["test"]}
EOF
}
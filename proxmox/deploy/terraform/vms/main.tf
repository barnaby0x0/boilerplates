terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.96.0"
    }
    # vault = {
    #   source  = "hashicorp/vault"
    #   version = "5.7.0"
    # }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_url
  api_token = var.api_token
  insecure  = true
  ssh {
    agent       = false
    username    = "root"
    private_key = file("~/.ssh/id_rsa")
  }
}


# provider "vault" {
#   address = "http://10.0.0.112:8200"

#   auth_login {
#     path = "auth/approle/login"
#     parameters = {
#       role_id   = var.vault_role_id
#       secret_id = var.vault_secret_id
#     }
#   }
# }

# data "vault_generic_secret" "registry_auth" {
#   path = "secret/terraform/test"
# }

# locals {
#   sectxt = data.vault_generic_secret.registry_auth.data["test"]
# }

# resource "local_file" "credentials" {
#   filename = "${path.module}/.env"
#   content  = <<EOF
# export TF_VAR_test=${data.vault_generic_secret.registry_auth.data["test"]}
# EOF
# }

# output "name" {
#   value = var.test
# }


variable "target_host" {
  description = "IP to test"
  type        = string
  default     = "10.0.0.112"
}

data "external" "server_reachable" {
  program = ["bash", "-c", <<EOT
    if nc -z -w 3 "${var.target_host}" 22 >/dev/null 2>&1; then
      echo '{"reachable": "true", "message": "OK"}'
    else
      echo '{"reachable": "false", "message": "Serveur ${var.target_host} non joignable (port 22)"}'
    fi
  EOT
  ]
}

check "server_must_be_up" {
  assert {
    condition     = data.external.server_reachable.result.reachable == "true"
    error_message = data.external.server_reachable.result.message
  }
}

resource "null_resource" "create_the_ressource" {
  depends_on = [data.external.server_reachable]
  count      = data.external.server_reachable.result.reachable == "true" ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'Nous pouvons créer le conteneur ${var.target_host}'"
  }
}
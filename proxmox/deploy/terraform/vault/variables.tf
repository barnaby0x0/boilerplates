# variable "vault_token" {
#   description = "Vault token for authentication"
#   type        = string
#   sensitive   = true
# }

variable "vault_role_id" {
  type        = string
  sensitive   = true
}

variable "vault_secret_id" {
  type        = string
  sensitive   = true
}
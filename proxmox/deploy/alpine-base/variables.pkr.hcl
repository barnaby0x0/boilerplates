# Variable Definitions
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "ssh_password" {
  type      = string
  sensitive = true
}

variable "cores" {
  type      = string
}

variable "memory" {
  type      = string
}

variable "http_bind_address" {
  type = string
}

variable "vm_id" {
  type = string
}
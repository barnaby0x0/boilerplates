# Proxmox connection object
variable "proxmox_connection" {
  description = "Proxmox connection info (url, token)"
  type = object({
    proxmox_url = string
    api_token   = string
  })
}

variable "proxmox_url" {
  type        = string
  description = "proxmox api url"
}

variable "api_token" {
  type        = string
  description = "proxmox api token"
}
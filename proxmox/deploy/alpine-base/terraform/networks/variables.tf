# Proxmox connection object
variable "proxmox_connection" {
  description = "Proxmox connection info (url, token)"
  type = object({
    proxmox_url = string
    api_token   = string
  })
}

variable "zones" {
  description = "zones list"
  type = list(object({
    id  = string
    mtu = optional(number)
  }))
}

variable "vnets" {
  description = "vnets list"
  type = list(object({
    id   = string
    zone = string
  }))
}

variable "subnets" {
  description = "vnets list"
  type = list(object({
    cidr    = string
    vnet    = string
    gateway = string
  }))
}
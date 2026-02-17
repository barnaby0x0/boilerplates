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

variable "security_groups" {
  description = "List of Security groups"
  type = list(object({
    name    = string
    comment = optional(string)
    deploy  = optional(bool, true)
    rules = list(object({
      action         = optional(string)
      comment        = optional(string)
      dest           = optional(string)
      dport          = optional(string)
      enabled        = optional(bool)
      iface          = optional(string)
      log            = optional(string)
      macro          = optional(string)
      proto          = optional(string)
      security_group = optional(string)
      source         = optional(string)
      sport          = optional(string)
      type           = optional(string)
    }))
  }))
}

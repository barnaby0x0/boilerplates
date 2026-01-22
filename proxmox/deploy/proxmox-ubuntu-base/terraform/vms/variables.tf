# Proxmox connection object
variable "proxmox_connection" {
  description = "Proxmox connection info (url, token)"
  type = object({
    proxmox_url = string
    api_token   = string
  })
}

# Multiple VM configs
variable "vm_configs" {
  description = "List of VM configurations"
  type = list(object({
    id          = string
    vm_id       = number
    hostname    = string
    domain      = string
    cpu_type    = string
    cpu_cores   = number
    cpu_sockets = number
    memory      = number
    vm_user     = string
    disk = optional(object({
      storage = string
      size    = number
    }))
    additionnal_disks = list(object({
      storage = string
      size    = number
    }))
    bridges            = list(string)
    vm_tags            = list(string)
    template_id        = string
    template_tag       = string
    started            = bool
    onboot             = bool
    target_node        = string
    target_node_domain = string
    # addresses          = list(list(string))
    dns_servers = list(string)
    nics = map(object({
      bridges   = string
      addresses = string
      gateway4  = string

      routes = optional(list(object({
        to     = string
        via    = string
        metric = optional(string)
        table  = optional(string)
        scope  = optional(string)
      })), [])
    }))
    users = list(object({
      name                = string
      password            = string
      groups              = string
      lock_passwd         = string
      sudo                = string
      shell               = string
      ssh_authorized_keys = string
    }))
    cmds   = list(string)
    deploy = bool
  }))
}

variable "api_token" {
  description = "Token to connect Proxmox API"
  type        = string
}

variable "proxmox_url" {
  description = "Proxmox url"
  type        = string
}

variable "target_node" {
  description = "Proxmox node"
  type        = string
  default     = "pve"
}

variable "started" {
  description = "The vm is started after creation"
  type        = bool
  default     = true
}

variable "onboot" {
  description = "Auto start VM when node is start"
  type        = bool
  default     = false
}

variable "target_node_domain" {
  description = "Proxmox node domain"
  type        = string
  default     = ""
}

variable "vm_hostname" {
  description = "VM hostname"
  type        = string
  default     = "immich"
}

variable "domain" {
  description = "VM domain"
  type        = string
  default     = "net.local"
}

variable "bridge" {
  description = "Network interface to use"
  type        = string
  default     = "vnet01"
}

variable "vm_tags" {
  description = "VM tags"
  type        = list(string)
  default     = ["router"]
}

variable "template_id" {
  description = "Template id"
  type        = string
  default     = "190"
}
variable "template_tag" {
  description = "Template tag"
  type        = string
  default     = "router"
}

# variable "docker_ports" {
#   type = list(object({
#     internal = number
#     external = number
#     protocol = string
#   }))
#   default = [
#     {
#       internal = 8300
#       external = 8300
#       protocol = "tcp"
#     }
#   ]
# }

variable "cpu_type" {
  description = "Type of cpu"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "cpu_sockets" {
  description = "Number of sockets"
  type        = number
  default     = 1
}

variable "cpu_cores" {
  description = "Number of cores"
  type        = number
  default     = 4
}

variable "memory" {
  description = "Number of memory in MB"
  type        = number
  default     = 4096
}

variable "vm_user" {
  description = "User"
  type        = string
  sensitive   = true
  default     = "sysadmin"
}

variable "disk" {
  description = "Disk (size in Gb)"
  type = object({
    storage = string
    size    = number
  })
  default = {
    storage = "local-lvm"
    size    = 100
  }
}

variable "additionnal_disks" {
  description = "Additionnal disks"
  type = list(object({
    storage = string
    size    = number
  }))
  default = []
}

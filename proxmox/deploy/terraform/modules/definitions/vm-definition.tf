variable "vm_configs" {
  description = "List of VM configurations"
  default     = []
  type = list(object({
    id          = string
    vm_id       = number
    hostname    = string
    domain      = string
    bios        = optional(string, "seabios")
    cpu_type    = optional(string, "x86-64-v2-AES")
    cpu_cores   = number
    cpu_sockets = number
    memory      = number
    vm_user     = string

    startup = optional(object({
      order      = optional(string)
      up_delay   = optional(string)
      down_delay = optional(string)
    }))

    disks = optional(map(object({
      interface = string
      storage   = string
      size      = number
      iothread  = bool
      discard   = string
    })))

    disk = optional(object({
      storage = string
      size    = number
    }))
    additionnal_disks = optional(list(object({
      storage = string
      size    = number
    })))
    vm_tags            = list(string)
    template_id        = string
    template_tag       = string
    started            = bool
    onboot             = bool
    target_node        = string
    target_node_domain = string
    dns_servers        = list(string)
    network_devices = map(object({
      bridge    = string
      model     = optional(string, "virtio")
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
    files = optional(list(object({
      path        = string
      permissions = string
      content     = string
    })))
    cmds   = list(string)
    deploy = bool
  }))
}

# locals {
#   vm_configs = var.vm_configs
# }

output "vm_configs" {
  value = var.vm_configs
}
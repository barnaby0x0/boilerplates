variable "proxmox_connection" {
  description = "Proxmox connection info (url, token)"
  type = object({
    proxmox_url    = string
    api_token      = optional(string)
    root_api_token = optional(string)
  })
}

# variable "proxmox_url" {
#   type        = string
#   description = "proxmox api url"
# }

# variable "api_token" {
#   type        = string
#   description = "proxmox api token"
# }

variable "ct_configs" {
  description = "List of Containers configurations"
  type = list(object({
    id          = string
    vm_id       = number
    description = string
    target_node = string
    tags        = list(string)
    hostname    = string
    cpu = optional(object({
      architecture = optional(string)
      cores        = optional(number)
      units        = optional(number)
    }))
    memory = optional(object({
      dedicated = optional(number)
      swap      = optional(number)
    }))
    network_interfaces = map(object({
      name   = string
      bridge = string
    }))
    ipv4_configs = map(object({
      address = string
      gateway = string
    }))
    disks = map(object({
      datastore_id = string
      size         = number
    }))

    unprivileged = bool
    features = optional(object({
      nesting = bool
      }), {
      nesting = true
    })
    start_on_boot = optional(bool, true)
    startup = optional(object({
      order      = string
      up_delay   = string
      down_delay = string
      }), {
      order      = "3"
      up_delay   = "60"
      down_delay = "60"
    })

    operating_system = optional(object({
      #template_file_id = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_lxc_img.id
      # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
      template_file_id = string
      type             = string
      }), {
      template_file_id = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
      type             = "ubuntu"
    })

    deploy              = bool
    hook_script_file_id = optional(string)
  }))
}


# variable "vm_configs" {
#   description = "List of VM configurations"
#   type = list(object({
#     id          = string
#     vm_id       = number
#     hostname    = string
#     domain      = string
#     cpu_type    = optional(string, "x86-64-v2-AES")
#     cpu_cores   = number
#     cpu_sockets = number
#     memory      = number
#     vm_user     = string

#     disks = optional(map(object({
#       interface = string
#       storage   = string
#       size      = number
#       iothread  = bool
#       discard   = string
#     })))

#     disk = optional(object({
#       storage = string
#       size    = number
#     }))
#     additionnal_disks = optional(list(object({
#       storage = string
#       size    = number
#     })))
#     bridges            = list(string)
#     vm_tags            = list(string)
#     template_id        = string
#     template_tag       = string
#     started            = bool
#     onboot             = bool
#     target_node        = string
#     target_node_domain = string
#     # addresses          = list(list(string))
#     dns_servers = list(string)
#     nics = map(object({
#       bridges   = string
#       addresses = string
#       gateway4  = string

#       routes = optional(list(object({
#         to     = string
#         via    = string
#         metric = optional(string)
#         table  = optional(string)
#         scope  = optional(string)
#       })), [])
#     }))
#     users = list(object({
#       name                = string
#       password            = string
#       groups              = string
#       lock_passwd         = string
#       sudo                = string
#       shell               = string
#       ssh_authorized_keys = string
#     }))
#     cmds   = list(string)
#     deploy = bool
#   }))
# }

# variable "api_token" {
#   description = "Token to connect Proxmox API"
#   type        = string
# }

# variable "proxmox_url" {
#   description = "Proxmox url"
#   type        = string
# }

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

variable "ct_configs" {
  description = "List of Containers configurations"
  default     = []
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
      order      = optional(string)
      up_delay   = optional(string)
      down_delay = optional(string)
    }), {})

    ssh_public_keys = optional(list(string), [])

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

output "ct_configs" {
  value = var.ct_configs
}
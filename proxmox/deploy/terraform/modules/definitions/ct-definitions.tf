variable "ct_configs" {
  description = "List of Containers configurations"
  default     = []
  type = list(object({
    id               = string
    replicas         = optional(number)
    vm_id            = number
    description      = string
    target_node      = string
    tags             = list(string)
    hostname         = string
    firewall_enabled = optional(bool, false)
    secgroups = optional(list(object({
      enabled        = optional(bool)
      comment        = optional(string)
      security_group = optional(string)
      iface          = optional(string)
    })))    
    fw_rules = optional(list(object({
      type           = optional(string)
      action         = optional(string)
      enabled        = optional(bool)
      comment        = optional(string)
      dest           = optional(string)
      dport          = optional(string)
      proto          = optional(string)
      log            = optional(string)
      iface          = optional(string)
      source         = optional(string)
      sport          = optional(string)
      macro          = optional(string)
      security_group = optional(string)
    })))
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
      name     = string
      bridge   = string
      firewall = optional(bool, false)
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
    }))

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


locals {
  expanded_ct_configs = flatten([
    for config in var.ct_configs : [
      for i in range(coalesce(config.replicas, 1)) :
      merge(
        config,
        {
          id       = coalesce(config.replicas, 0) >= 1 ? "${config.id}_${i + 1}" : config.id
          hostname = coalesce(config.replicas, 0) >= 1 ? "${config.hostname}-${i + 1}" : config.hostname
          vm_id    = config.vm_id + i
          ipv4_configs = {
            for k, v in config.ipv4_configs : k => merge(v, {
              address = (
                length(regexall("/", v.address)) > 0 ?
                format(
                  "%s.%d/%s",
                  join(".", slice(split(".", split("/", v.address)[0]), 0, 3)),
                  tonumber(element(split(".", split("/", v.address)[0]), 3)) + i,
                  split("/", v.address)[1]
                ) :
                format(
                  "%s.%d",
                  join(".", slice(split(".", v.address), 0, 3)),
                  tonumber(element(split(".", v.address), 3)) + i
                )
              )
            })
          }
        }
      )
    ]
  ])
}

output "expanded_ct_configs" {
  value = local.expanded_ct_configs
}

output "ct_configs" {
  value = local.expanded_ct_configs
  # value = var.ct_configs
}
variable "vm_configs" {
  description = "List of VM configurations"
  default     = []
  type = list(object({
    id               = string
    replicas         = optional(number)
    vm_id            = number
    hostname         = string
    domain           = string
    bios             = optional(string, "seabios")
    boot_order       = optional(list(string))
    cpu_type         = optional(string, "x86-64-v2-AES")
    cpu_cores        = number
    cpu_sockets      = number
    memory           = number
    vm_user          = string
    agent            = optional(bool, true)
    firewall_enabled = optional(bool, false)

    startup = optional(object({
      order      = optional(string)
      up_delay   = optional(string)
      down_delay = optional(string)
    }))
    efi_disk = optional(object({
      datastore_id      = optional(string, "local-lvm")
      file_format       = optional(string, "raw")
      type              = optional(string, "4m")
      pre_enrolled_keys = optional(bool, false)
    }))
    disks = optional(map(object({
      interface = string
      storage   = string
      size      = number
      iothread  = bool
      discard   = string
    })))
    cdrom = optional(object({
      file_id = string
    }))
    disk = optional(object({
      storage = string
      size    = number
    }))
    additionnal_disks = optional(list(object({
      storage = string
      size    = number
    })))
    vm_tags            = list(string)
    template_id        = optional(string)
    template_tag       = optional(string)
    started            = bool
    onboot             = bool
    target_node        = string
    target_node_domain = string
    dns_servers        = optional(list(string))
    network_devices = optional(map(object({
      bridge    = string
      model     = optional(string, "virtio")
      dhcp      = optional(bool, false)
      addresses = optional(string)
      gateway4  = optional(string)
      firewall  = optional(bool)

      routes = optional(list(object({
        to     = string
        via    = string
        metric = optional(string)
        table  = optional(string)
        scope  = optional(string)
      })), [])
    })))
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
    users = optional(list(object({
      name                = string
      password            = string
      groups              = string
      lock_passwd         = string
      sudo                = string
      shell               = string
      ssh_authorized_keys = string
    })))
    files = optional(list(object({
      path        = string
      permissions = string
      content     = string
      owner       = optional(string)
    })))
    cmds              = list(string)
    enable_cloud_init = optional(bool, true)
    deploy            = bool
  }))
}

locals {
  # Transformation de la liste vm_configs pour prendre en compte replicas
  expanded_vm_configs = flatten([
    for config in var.vm_configs : [
      for i in range(coalesce(config.replicas, 1)) :
      merge(
        config,
        {
          # On suffixe l'id seulement si replicas > 1 (ou absent mais >1)
          id       = coalesce(config.replicas, 0) >= 1 ? "${config.id}_${i + 1}" : config.id
          hostname = coalesce(config.replicas, 0) >= 1 ? "${config.hostname}-${i + 1}" : config.hostname
          vm_id    = config.vm_id + i


          # Adaptation des adresses IP (incrémentation du dernier octet)
          network_devices = {
            for k, v in config.network_devices : k => merge(v, {
              addresses = v.addresses != null ? (
                length(regexall("/", v.addresses)) > 0 ?
                format(
                  "%s.%d/%s",
                  join(".", slice(split(".", split("/", v.addresses)[0]), 0, 3)),
                  tonumber(element(split(".", split("/", v.addresses)[0]), 3)) + i,
                  split("/", v.addresses)[1]
                ) :
                format(
                  "%s.%d",
                  join(".", slice(split(".", v.addresses), 0, 3)),
                  tonumber(element(split(".", v.addresses), 3)) + i
                )
              ) : null
            })
          }
        }
      )
    ]
  ])
}

output "expanded_vm_configs" {
  value = local.expanded_vm_configs
}

output "vm_configs" {
  value = local.expanded_vm_configs
  # value = var.vm_configs
}
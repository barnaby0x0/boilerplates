resource "proxmox_virtual_environment_file" "cloud_user_config" {
  for_each     = { for vm in var.vm_configs : vm.id => vm if vm.deploy }
  content_type = "snippets"
  datastore_id = "snippets"
  node_name    = var.target_node

  source_raw {
    data = templatefile("cloud-init/user_data", {
      users = each.value.users
      files = each.value.files
      cmds  = each.value.cmds
    })
    file_name = "${each.value.hostname}-ci-user.yml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_network_config" {
  for_each = { for vm in var.vm_configs : vm.id => vm if vm.deploy }

  content_type = "snippets"
  datastore_id = "snippets"
  node_name    = var.target_node
  #source_raw {
  #  data      = file("cloud-init/network_data")
  #  file_name = "${var.vm_hostname}-ci-network.yml"
  #}

  source_raw {
    data = templatefile("cloud-init/network_data", {
      nics        = each.value.nics
      dns_servers = format("[%s]", join(", ", [for s in each.value.dns_servers : "\"${s}\""]))
    })
    file_name = "${each.value.hostname}-ci-network.yml"
  }

}

# resource "proxmox_virtual_environment_file" "cloud_network_config" {
#   content_type = "snippets"
#   datastore_id = "snippets"
#   node_name    = var.target_node
#   source_raw {
#     data = templatefile("cloud-init/network_data", {
#       ADDRESSES = join(", ", each.value.addresses)
#     })
#     file_name = "${var.vm_hostname}-ci-network.yml"
#   }
# }

resource "proxmox_virtual_environment_file" "cloud_meta_config" {
  content_type = "snippets"
  datastore_id = "snippets" # Utiliser le stockage dédié
  node_name    = var.target_node

  source_raw {
    data = templatefile("cloud-init/meta_data",
      {
        instance_id    = sha1(var.vm_hostname)
        local_hostname = var.vm_hostname
      }
    )

    file_name = "${var.vm_hostname}.${var.domain}-ci-meta_data.yml"
  }
}

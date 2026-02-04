resource "proxmox_virtual_environment_container" "ct" {
  for_each = { for ct in local.configs : ct.id => ct if ct.deploy }

  description = each.value.description
  tags        = each.value.tags

  vm_id     = each.value.vm_id
  node_name = each.value.target_node

  cpu {
    cores = each.value.cpu.cores
  }
  memory {
    dedicated = each.value.memory.dedicated
  }

  dynamic "network_interface" {
    for_each = each.value.network_interfaces
    content {
      name   = network_interface.value.name
      bridge = network_interface.value.bridge
    }
  }

  dynamic "disk" {
    for_each = each.value.disks
    content {
      datastore_id = disk.value.datastore_id
      size         = disk.value.size
    }
  }

  initialization {
    hostname = each.value.hostname

    ip_config {
      dynamic "ipv4" {
        for_each = each.value.ipv4_configs
        content {
          address = ipv4.value.address
          gateway = ipv4.value.gateway
        }
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.ubuntu_container_key.public_key_openssh)
      ]
      password = random_password.ubuntu_container_password.result
    }
  }

  unprivileged = each.value.unprivileged

  features {
    nesting = each.value.features.nesting
  }

  operating_system {
    template_file_id = each.value.operating_system.template_file_id
    type             = each.value.operating_system.type
  }

  startup {
    order      = each.value.startup.order
    up_delay   = each.value.startup.up_delay
    down_delay = each.value.startup.down_delay
  }
  #hook_script_file_id = proxmox_virtual_environment_file.hook_script.id
}

# resource "proxmox_virtual_environment_file" "hook_script" {
#   #provider     = proxmox.root
#   content_type = "snippets"
#   datastore_id = "snippets"
#   node_name    = "pve"
#   # Hook scripts must be executable, otherwise the Proxmox VE API will reject the configuration for the VM/CT.
#   file_mode = "0700"

#   source_raw {
#     data      = <<-EOF
#       #!/usr/bin/env bash
#       pct exec 910 -- bash -c 'apt-get update && apt-get install curl -y'
#       pct exec 910 -- bash -c 'mkdir -p /root/nginx'
#       pct exec 910 -- bash -c 'curl http://192.168.1.29:8080/files/nginxproxymanager/configs/docker-compose.yml -o /root/nginx/docker-compose.yml'
#       EOF
#     file_name = "prepare-hook.sh"
#   }
# }


# resource "proxmox_virtual_environment_file" "hook_script" {
#   content_type = "snippets"
#   datastore_id = "snippets"
#   node_name    = "pve"
#   file_mode    = "0700"

#   source_raw {
#     data = <<-EOF
#       #!/usr/bin/env bash

#       echo "DEBUG: ARGS = '$@'" >&2
#       echo "DEBUG: \$1 = '$1'" >&2  
#       echo "DEBUG: \$2 = '$2'" >&2
#       VMID=$1
#       PHASE=$2
#       echo "DEBUG: VMID=\$VMID PHASE=\$PHASE" >&2


#       # Hookscript pour CT $1, phase $2


#       case "$PHASE" in
#         pre-start)
#           echo "Pre-start pour CT $VMID: préparation" >&2
#           # Ici: commandes avant démarrage (ex: créer des fichiers)
#           ;;
#         post-start)
#           echo "Post-start pour CT $VMID: CT démarré, réseau up" >&2
#           # ATTENTION: $VMID est dynamique, pas hardcodé 910 !
#           pct exec $VMID -- bash -c 'apt-get update && apt-get install -y curl'
#           pct exec $VMID -- bash -c 'mkdir -p /root/nginx'
#           pct exec $VMID -- bash -c 'curl http://192.168.1.29:8080/files/nginxproxymanager/configs/docker-compose.yml -o /root/nginx/docker-compose.yml'
#           ;;
#         pre-stop)
#           echo "Pre-stop pour CT $VMID: arrêt" >&2
#           ;;
#         *)
#           echo "Phase inconnue: $PHASE" >&2
#           exit 1
#           ;;
#       esac
#       EOF
#     file_name = "prepare-hook.sh"
#   }
# }


#resource "proxmox_virtual_environment_download_file" "latest_ubuntu_22_jammy_lxc_img" {
#  content_type = "vztmpl"
#  datastore_id = "local"
#  node_name    = "first-node"
#  url          = "http://download.proxmox.com/images/system/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
#}

resource "random_password" "ubuntu_container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ubuntu_container_password" {
  value     = random_password.ubuntu_container_password.result
  sensitive = true
}

output "ubuntu_container_private_key" {
  value     = tls_private_key.ubuntu_container_key.private_key_pem
  sensitive = true
}

output "ubuntu_container_public_key" {
  value = tls_private_key.ubuntu_container_key.public_key_openssh
}

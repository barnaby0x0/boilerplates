resource "proxmox_virtual_environment_container" "ubuntu_container" {
  description = "Wireguard Managed by Terraform"
  tags        = ["wireguard"]
  node_name   = "pve"
  vm_id       = 200

  initialization {
    hostname = "wg-container"

    ip_config {
      ipv4 {
        #address = "dhcp"
        address = "192.168.1.103/24"
        gateway = "192.168.1.1"
      }
    }
    ip_config {
      ipv4 {
        #address = "dhcp"
        address = "10.0.0.3/24"
        gateway = "10.0.0.1"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.ubuntu_container_key.public_key_openssh)
      ]
      password = random_password.ubuntu_container_password.result
    }
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  network_interface {
    name   = "eth1"
    bridge = "vnet01"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  unprivileged = true

  features {
    nesting = true
  }

  operating_system {
    #template_file_id = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_lxc_img.id
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    template_file_id = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
    type             = "ubuntu"
  }

  #  mount_point {
  #    # bind mount, *requires* root@pam authentication
  #    volume = "/mnt/bindmounts/shared"
  #    path   = "/mnt/shared"
  #  }

  #mount_point {
  ## volume mount, a new volume will be created by PVE
  #volume = "local-lvm"
  #size   = "10G"
  #path   = "/mnt/volume"
  #}

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
}

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

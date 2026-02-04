# Ubuntu Server Focal
# ---
# Packer Template to create an Ubuntu Server (Focal) on Proxmox

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "ssh_password" {
  type      = string
  sensitive = true
}

variable "cores" {
  type      = string
}

variable "memory" {
  type      = string
}

variable "http_bind_address" {
  type = string
}

variable "vm_id" {
  type = string
}

locals {
  disk_storage = "local-lvm"
}

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu-server-focal" {

  # Proxmox Connection Settings
  proxmox_url              = "${var.proxmox_api_url}"
  username                 = "${var.proxmox_api_token_id}"
  token                    = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = true
  # (Optional) Skip TLS Verification
  # insecure_skip_tls_verify = true

  # VM General Settings
  node                 = "pve"
  vm_id                = "${var.vm_id}"
  vm_name              = "ubuntu-server-focal"
  template_description = "Ubuntu Server Focal Image"

  # VM OS Settings
  # (Option 1) Local ISO File
  boot_iso {
    type         = "scsi"
    iso_file     = "local:iso/ubuntu-24.04.3-live-server-amd64.iso"
    unmount      = true
    iso_checksum = "d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
  }
  # (Option 2) Download ISO
  #boot_iso {
  #  type             = "scsi"
  #  iso_url          = "https://releases.ubuntu.com/24.04/ubuntu-24.04.2-live-server-amd64.iso"
  #  unmount          = true
  #  iso_storage_pool = "local"
  #  iso_checksum     = "d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
  #}

  # VM System Settings
  qemu_agent = true

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size    = "8G"
    format       = "raw"
    storage_pool = "${local.disk_storage}"
    type         = "virtio"
  }

  # VM CPU Settings
  cores = var.cores

  # VM Memory Settings
  memory = var.memory

  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "${local.disk_storage}"

  # PACKER Boot Commands

  boot      = "c"
  boot_wait = "2s"
  #boot_command = [
  #  "<esc><wait>",
  #  "e<wait>",
  #  "<down><down><down><end>",
  #  "<bs><bs><bs><bs><wait>",
  #  "autoinstall ds=nocloud-net\\;s=http://192.168.1.240:8080/  --- <wait>",
  #  "<f10><wait>"
  #]
  # - Or -
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}/ubuntu-server-focal-base  --- <wait>",
    "<f10><wait>"
  ]

  # Useful for debugging
  # Sometimes lag will require this
  # boot_key_interval = "500ms"

  # PACKER Autoinstall Settings
  # http_directory = "ubuntu-server-focal"
  # (Optional) Bind IP Address and Port
  http_bind_address = "${var.http_bind_address}"
  # http_port_min     = 8080
  # http_port_max     = 8080
  # http_port     = 8080
  ssh_username = "ubuntu"

  # (Option 1) Add your Password here
  ssh_password = "${var.ssh_password}"
  # - or -
  # (Option 2) Add your Private SSH KEY file here
  #ssh_private_key_file = "~/.ssh/id_ed25519"

  # Raise the timeout, when installation takes longer
  ssh_timeout = "20m"
  tags        = "packer;ubuntu"
}

# Build Definition to create the VM Template
build {

  name    = "ubuntu-server-focal"
  sources = ["source.proxmox-iso.ubuntu-server-focal"]
  
  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt-get -y autoremove --purge",
      "sudo apt-get -y clean",
      "sudo apt-get -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo sync",
      "sudo ssh-keygen -A",
      "sudo systemctl enable --now ssh.service"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  ## Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }

	provisioner "shell" {
	  script = "./scripts/install-docker.sh"
	}
  
}

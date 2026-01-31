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

variable "ssh_username" {
  type      = string
  sensitive = true
}

variable "ssh_password" {
  type      = string
  sensitive = true
}

variable "cores" {
  type = string
}

variable "memory" {
  type = string
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
source "proxmox-iso" "alpine" {

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
  vm_name              = "alpine"
  template_description = "Alpine Image"

  # VM OS Settings
  # (Option 1) Local ISO File
  boot_iso {
    type         = "scsi"
    iso_file     = "local:iso/alpine-standard-3.23.3-x86_64.iso"
    unmount      = true
    iso_checksum = "966d6bf4d4c79958d43abde84a3e5bbeb4f8c757c164a49d3ec8432be6d36f16"
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
  qemu_agent = false

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size    = "15G"
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
  boot_wait = "10s"
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
    "root<enter><wait>",
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait5>",
    "wget http://{{ .HTTPIP }}/alpine/answers<enter><wait>",
    "wget http://{{ .HTTPIP }}/alpine/configure<enter><wait>",
    "export ERASE_DISKS=/dev/vda<enter>",
    "export USEROPTS='-a -u -g audio,video,netdev user'<enter>",
    "export USERSSHKEY='http://{{ .HTTPIP }}/alpine/ssh.keys'<enter>",
    "setup-alpine -f $PWD/answers<enter><wait10>",
    "toor<enter><wait>",
    "toor<enter><wait15>",
    "sh configure<enter>"
    #";ount >dev>vdq# >;nt<enter>"
    #"echo 4Per;itRootLogin yes4 // >;nt>etc>sshd8config<enter>",
    #"mount /dev/vda3 /mnt<enter>",
    #"echo 'PermitRootLogin yes' >> /mnt/etc/ssh/sshd_config<enter>",    
    #"reboot<enter>"
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
  ssh_host     = "192.168.1.109"
  ssh_username = "root"

  # (Option 1) Add your Password here
  ssh_password = "${var.ssh_password}"
  # - or -
  # (Option 2) Add your Private SSH KEY file here
  #ssh_private_key_file = "~/.ssh/id_ed25519"

  # Raise the timeout, when installation takes longer
  ssh_timeout = "20m"
  tags        = "packer;router"
}

# Build Definition to create the VM Template
build {

  name    = "alpine"
  sources = ["source.proxmox-iso.alpine"]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    inline = [
      "apk --no-cache --cache-max-age 30 add qemu-guest-agent cloud-init py3-netifaces sudo util-linux e2fsprogs-extra",
      "rc-update add qemu-guest-agent",
      "rc-update add cloud-init default",
      "rc-update add cloud-init-local default",
      "setup-cloud-init"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  ## Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = [
      "mkdir -p /etc/cloud/cloud.cfg.d",
      "cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg",
      "sed -i '/iface eth0 inet static/,/gateway/d' /etc/network/interfaces",
      "sed -i '/auto eth0/a iface eth0 inet dhcp' /etc/network/interfaces"
    ]
  }

  provisioner "shell" {
    script = "./scripts/install-docker.sh"
  }

}

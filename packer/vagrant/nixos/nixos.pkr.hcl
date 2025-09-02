packer {
  required_plugins {
    vagrant = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

locals {
  build_dir     = "${var.home_dir}/releases/packer/base_boxes/${var.name}${var.version}/${var.archetype}"
  file_basename = "${var.name}${var.version}-${var.archetype}"
}

variable "archetype" {
  type = string
}

variable "boot_wait" {
  type = string
}

variable "format" {
  type    = string
  default = "qcow2"
}

variable "home_dir" {
  type    = string
  default = env("HOME")
}

variable "host_port_max" {
  type    = number
  default = 2229
}

variable "host_port_min" {
  type    = number
  default = 2222
}

variable "http_port_max" {
  type    = number
  default = 10089
}

variable "http_port_min" {
  type    = number
  default = 10082
}

variable "http_directory" {
  type    = string
  default = "./scripts"
}

variable "iso_checksum" {
  type = string
}

variable "iso_url" {
  type = string
}

variable "name" {
  type = string
}

variable "ssh_timeout" {
  type    = string
  default = "30m"
}

variable "version" {
  type = string
}

variable "cpu" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "20000"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "ram" {
  type    = string
  default = "2048"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
}

variable "ssh_private_key_file" {
  type    = string
  default = "./scripts/install_ed25519"
}

variable "ssh_username" {
  type    = string
  default = "nixos"
}

variable "net_device" {
  type    = string
  default = "virtio-net"
}

variable "qemu_binary" {
  type    = string
  default = "/usr/bin/qemu-system-x86_64"
}

variable "disk_interface" {
  type    = string
  default = "virtio-scsi"
}

variable "INSTALL_LOCAL" {
  type    = string
  default = "true"
}

source "qemu" "nixos" {
  accelerator = "kvm"
  boot_command = [
    "mkdir -m 0700 .ssh<enter>",
    "curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/install_ed25519.pub > .ssh/authorized_keys<enter>",
    "sudo systemctl start sshd<enter>"
  ]
  boot_wait        = var.boot_wait
  disk_cache       = "none"
  disk_compression = true
  disk_discard     = "unmap"
  disk_interface   = var.disk_interface
  disk_size        = var.disk_size
  format           = var.format
  headless         = var.headless
  host_port_max    = var.host_port_max
  host_port_min    = var.host_port_min
  http_directory   = var.http_directory
  http_port_max    = var.http_port_max
  http_port_min    = var.http_port_min
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  net_device       = var.net_device
  output_directory = "${local.build_dir}"
  vm_name          = "${local.file_basename}.${var.format}"
  qemu_binary      = var.qemu_binary
  qemuargs = [
    ["-m", "${var.ram}M"],
    ["-smp", "${var.cpu}"],
    ["-netdev", "user,hostfwd=tcp::{{ .SSHHostPort }}-:22,id=forward"],
    ["-device", "virtio-net,netdev=forward,id=net0"],
    ["-device", "virtio-scsi-pci,id=scsi0"],
    ["-device", "scsi-hd,bus=scsi0.0,drive=drive0"]
  ]
  shutdown_command     = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  ssh_private_key_file = var.ssh_private_key_file
  ssh_username         = var.ssh_username
  ssh_timeout          = var.ssh_timeout
}

build {
  sources = [
    "source.qemu.nixos",
  ]

  provisioner "shell" {
    execute_command = "sudo su -c '{{ .Vars }} {{ .Path }}'"
    script          = "./scripts/install.sh"
    environment_vars = [
      "INSTALL_LOCAL=${var.INSTALL_LOCAL}"
    ]
  }

  post-processor "vagrant" {
    compression_level   = 6
    keep_input_artifact = true
    output              = "${local.build_dir}/${local.file_basename}.box"
  }

  post-processor "shell-local" {
    inline = [
      "qemu-img convert -f qcow2 -O raw ${local.build_dir}/${local.file_basename}.qcow2 ${local.build_dir}/${local.file_basename}.raw",
    ]
  }

}

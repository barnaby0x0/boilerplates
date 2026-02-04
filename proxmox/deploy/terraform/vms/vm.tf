resource "proxmox_virtual_environment_vm" "vm" {
  #for_each = { for vm in var.vm_configs : vm.id => vm if vm.deploy }
  for_each = { for vm in local.configs : vm.id => vm if vm.deploy }

  vm_id     = each.value.vm_id
  name      = "${each.value.hostname}.${each.value.domain}"
  node_name = each.value.target_node

  on_boot = each.value.onboot
  started = each.value.started

  agent { enabled = true }
  clone { vm_id = each.value.template_id }

  tags = each.value.vm_tags
  cpu {
    type    = each.value.cpu_type
    cores   = each.value.cpu_cores
    sockets = each.value.cpu_sockets
    flags   = []
  }

  memory { dedicated = each.value.memory }

  dynamic "network_device" {
    for_each = each.value.network_devices
    content {
      bridge = network_device.value.bridge
      model  = network_device.value.model
    }
  }

  # dynamic "network_device" {
  #   for_each = each.value.bridges
  #   content {
  #     #bridge = each.value.bridge
  #     bridge = network_device.value
  #     model  = "virtio"
  #   }
  # }

  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }

  # boot_order    = ["scsi0"]
  scsi_hardware = "virtio-scsi-single"

  # disk {
  #   interface    = "virtio0"
  #   iothread     = true
  #   datastore_id = each.value.disk.storage
  #   size         = each.value.disk.size
  #   discard      = "ignore"
  # }

  dynamic "disk" {
    for_each = each.value.disks
    content {
      interface    = disk.value.interface
      iothread     = disk.value.iothread
      datastore_id = disk.value.storage
      size         = disk.value.size
      discard      = disk.value.discard
    }
  }

  initialization {
    datastore_id      = "local-lvm"
    interface         = "ide2"
    user_data_file_id = proxmox_virtual_environment_file.cloud_user_config[each.key].id
    #user_data_file_id    = proxmox_virtual_environment_file.cloud_user_config.id
    meta_data_file_id    = proxmox_virtual_environment_file.cloud_meta_config[each.key].id
    network_data_file_id = proxmox_virtual_environment_file.cloud_network_config[each.key].id
  }
}

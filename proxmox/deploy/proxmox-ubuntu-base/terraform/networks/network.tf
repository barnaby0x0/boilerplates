resource "proxmox_virtual_environment_sdn_applier" "vnet_applier" {
  depends_on = [
    proxmox_virtual_environment_sdn_zone_simple.this,
    proxmox_virtual_environment_sdn_vnet.this,
    proxmox_virtual_environment_sdn_subnet.this
  ]
}

resource "proxmox_virtual_environment_sdn_applier" "finalizer" {
}

resource "proxmox_virtual_environment_sdn_zone_simple" "this" {
  for_each = { for zone in var.zones : zone.id => zone }
  id       = each.value.id
  depends_on = [
    proxmox_virtual_environment_sdn_applier.finalizer
  ]
}

resource "proxmox_virtual_environment_sdn_vnet" "this" {
  for_each = { for vnet in var.vnets : vnet.id => vnet }
  id       = each.value.id
  zone     = each.value.zone

  depends_on = [
    proxmox_virtual_environment_sdn_applier.finalizer,
    proxmox_virtual_environment_sdn_zone_simple.this
  ]
}

resource "proxmox_virtual_environment_sdn_subnet" "this" {
  for_each = { for subnet in var.subnets : subnet.cidr => subnet }
  cidr     = each.value.cidr
  vnet     = each.value.vnet
  gateway  = each.value.gateway

  depends_on = [
    proxmox_virtual_environment_sdn_applier.finalizer,
    proxmox_virtual_environment_sdn_vnet.this
  ]
}
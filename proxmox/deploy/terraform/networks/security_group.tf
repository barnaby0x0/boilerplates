resource "proxmox_virtual_environment_cluster_firewall_security_group" "webserver" {
  for_each = { for sg in var.security_groups : sg.name => sg if sg.deploy }

  name    = each.value.name
  comment = each.value.comment
  # name     = "test700"
  # comment  = "Managed by Terraform"
  dynamic "rule" {
    for_each = try(each.value.rules, null) == null ? [] : each.value.rules
    content {
      action  = rule.value.action
      comment = rule.value.comment
      dest    = rule.value.dest
      dport   = rule.value.dport
      enabled = rule.value.enabled
      iface   = rule.value.iface
      log     = rule.value.log
      macro   = rule.value.macro
      proto   = rule.value.proto
      source  = rule.value.source
      sport   = rule.value.sport
      type    = rule.value.type
    }
  }
}


resource "proxmox_virtual_environment_node_firewall" "pve1" {
  node_name           = "pve"
  enabled             = true
  log_level_in        = "nolog"
  log_level_out       = "nolog"
  log_level_forward   = "nolog"
  ndp                 = true
  nftables            = false
  nosmurfs            = true
  smurf_log_level     = "nolog"
  tcp_flags_log_level = "nolog"
}
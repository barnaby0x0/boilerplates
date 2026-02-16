resource "proxmox_virtual_environment_cluster_firewall_security_group" "webserver" {
  name    = "test700"
  comment = "Managed by Terraform"

  rule {
    type    = "out"
    action  = "ACCEPT"
    comment = "Allow HTTP SERVER"
    dest    = "192.168.1.29"
    dport   = "8080"
    proto   = "tcp"
    log     = "nolog"
  }

  rule {
    type    = "out"
    action  = "DROP"
    comment = "Block all local network"
    dest    = "192.168.1.0/24"
    log     = "nolog"
  }

  rule {
    type    = "out"
    action  = "ACCEPT"
    comment = "Allow all external"
    log     = "nolog"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    macro = "SSH"
    comment = "Allow ssh from rpi router"
    source = "router-rpi"
    log     = "nolog"
  }  

}
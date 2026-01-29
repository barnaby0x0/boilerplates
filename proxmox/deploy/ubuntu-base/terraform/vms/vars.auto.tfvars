proxmox_url = "https://192.168.1.100:8006/api2/json"
api_token   = "terraform@pve!automation=ccbf32e0-02bd-423e-9030-989e2a47050b"

proxmox_connection = {
  proxmox_url = "https://192.168.1.100:8006/api2/json"
  api_token   = "terraform@pve!automation=ccbf32e0-02bd-423e-9030-989e2a47050b"
}

vm_configs = [
  {
    id          = "A"
    vm_id       = 600
    hostname    = "router"
    domain      = "net.local"
    cpu_type    = "x86-64-v2-AES"
    cpu_cores   = 4
    cpu_sockets = 1
    memory      = 4096
    vm_user     = "sysadmin"
    disks = {
      disk0 = {
        interface = "virtio0"
        storage   = "local-lvm"
        size      = 30
        iothread  = true
        discard   = "ignore"
      }
      disk1 = {
        interface = "virtio1"
        storage   = "local-lvm"
        size      = 20
        iothread  = true
        discard   = "ignore"
      }
    }
    bridges            = [
      "vmbr0", 
      # "vnet01", 
      # "vneta1", 
      # "vnetb1"
      ]
    vm_tags            = ["router"]
    template_id        = "191"
    template_tag       = "router"
    started            = true
    onboot             = false
    target_node        = "pve"
    target_node_domain = ""
    dns_servers        = ["8.8.8.8", "8.8.4.4"]
    nics = {
      ens18 = {
        bridges   = "vmbr0"
        addresses = "192.168.1.113/24"
        gateway4  = "192.168.1.1"
        routes = [
          {
            to     = "default"
            via    = "192.168.1.1"
            metric = "10"
          }
        ]
      }
      # ens19 = {
      #   bridges   = "vnet01"
      #   addresses = "10.0.0.254/24"
      #   gateway4  = "10.0.0.1"
      #   routes = [
      #     {
      #       to     = "default"
      #       via    = "10.0.0.1"
      #       metric = "10"
      #     }
      #   ]
      # }
      # ens20 = {
      #   bridges   = "vneta1"
      #   addresses = "10.11.0.254/24"
      #   gateway4  = "10.11.0.1"
      #   routes = [
      #     {
      #       to     = "default"
      #       via    = "10.11.0.1"
      #       metric = "10"
      #     }
      #   ]
      # }
      # ens21 = {
      #   bridges   = "vnetb1"
      #   addresses = "10.12.0.254/24"
      #   gateway4  = "10.12.0.1"
      #   routes = [
      #     {
      #       to     = "default"
      #       via    = "10.12.0.1"
      #       metric = "10"
      #     }
      #   ]
      # }
    }
    users = [{
      name                = "user"
      password            = "$6$tGz.h5alKsD5IOP2$yfQ1RTnXjdLnmCQxFG70Jf3d24YAb8Bsb/qZ/iW0aokkahPQ8qlRhgC2ZpVYkcK.CQh579k3IF3f2LTDAMsKH/"
      groups              = "[adm, sudo]"
      lock_passwd         = "false"
      sudo                = "ALL=(ALL) NOPASSWD:ALL"
      shell               = "/bin/bash"
      ssh_authorized_keys = "\n      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1oFq0GYt8j7vg2nNAJNzwBtqrdOUDp8CMQwLRiz4Vz user@ull"
    }]
    cmds = [
      "sysctl -w net.ipv4.ip_forward=1",
      "iptables-restore < /opt/iptables.rules"
    ]
    deploy = true
  }
]

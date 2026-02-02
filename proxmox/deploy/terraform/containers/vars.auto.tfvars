proxmox_connection = {
  proxmox_url = "https://192.168.1.100:8006/api2/json"
  api_token   = "terraform@pve!automation=ccbf32e0-02bd-423e-9030-989e2a47050b"
}

ct_configs = [
  {
    id          = "lvm_testing"
    vm_id       = 105
    target_node = "pve"
    description = "Container managed by terraform for testing purpose."
    tags        = ["test", "terraform"]
    hostname    = "test-container"
    cpu = {
      cores = 2
    }
    memory = {
      dedicated = 1024
    }
    network_interfaces = {
      eth0 = {
        name   = "eth0"
        bridge = "vmbr0"
      }
      #   eth1 = {
      #     name   = "eth1"
      #     bridge = "vnet01"
      #   }
    }
    ipv4_configs = {
      eth0 = {
        #address = "dhcp"
        address = "192.168.1.105/24"
        gateway = "192.168.1.1"
      }
    }
    disks = {
      disk0 = {
        datastore_id = "local-lvm"
        size         = 4
      }
    }
    unprivileged = true
    deploy       = false
  },
  {
    id          = "nfs_server"
    vm_id       = 950
    target_node = "pve"
    description = "Container managed by terraform for nfs server."
    tags        = ["support", "netwoork", "terraform"]
    hostname    = "nfs-server"
    cpu = {
      cores = 2
    }
    memory = {
      dedicated = 1024
    }
    network_interfaces = {
      eth0 = {
        name   = "eth0"
        bridge = "vmbr0"
      }
      #   eth1 = {
      #     name   = "eth1"
      #     bridge = "vnet01"
      #   }
    }
    ipv4_configs = {
      eth0 = {
        #address = "dhcp"
        address = "192.168.1.115/24"
        gateway = "192.168.1.1"
      }
    }
    disks = {
      disk0 = {
        datastore_id = "local-lvm"
        size         = 4
      }
    }
    unprivileged = true
    deploy       = false
  },
  {
    id          = "vpn"
    vm_id       = 910
    target_node = "pve"
    description = "Container managed by terraform: vpn entrypoint"
    tags        = ["support", "network", "vpn", "terraform"]
    hostname    = "vpn"
    cpu = {
      cores = 1
    }
    memory = {
      dedicated = 512
    }
    network_interfaces = {
      eth0 = {
        name   = "eth0"
        bridge = "vmbr0"
      }
    }
    ipv4_configs = {
      eth0 = {
        address = "192.168.1.201/24"
        gateway = "192.168.1.1"
      }
    }
    disks = {
      disk0 = {
        datastore_id = "local-lvm"
        size         = 4
      }
    }
    unprivileged        = true
    deploy              = true
    hook_script_file_id = ""
  }

]

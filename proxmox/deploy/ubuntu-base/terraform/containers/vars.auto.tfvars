#proxmox_url = "https://192.168.1.99:8006/api2/json"
#api_token   = "root@pam!packer=98350077-6aa0-4587-bab4-995a80c76246"
proxmox_url = "https://192.168.1.100:8006/api2/json"
api_token   = "terraform@pve!automation=ccbf32e0-02bd-423e-9030-989e2a47050b"


ct_configs = [
  {
    id          = "lvm_testing"
    vm_id       = 105
    target_node = "pve"
    description = "Container managed by terraform for testing purpose."
    tags        = ["test"]
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
  }
]

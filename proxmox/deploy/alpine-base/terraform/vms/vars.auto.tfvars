proxmox_url = "https://192.168.1.100:8006/api2/json"
api_token   = "terraform@pve!automation=ccbf32e0-02bd-423e-9030-989e2a47050b"

proxmox_connection = {
  proxmox_url = "https://192.168.1.100:8006/api2/json"
  api_token   = "terraform@pve!automation=ccbf32e0-02bd-423e-9030-989e2a47050b"
}

vm_configs = [
  {
    id          = "nginx"
    vm_id       = 111
    hostname    = "nginx"
    domain      = "net.local"
    cpu_type    = "x86-64-v2-AES"
    cpu_cores   = 2
    cpu_sockets = 1
    memory      = 1024
    vm_user     = "sysadmin"
    disks = {
      disk0 = {
        interface = "virtio0"
        storage   = "local-lvm"
        size      = 15
        iothread  = true
        discard   = "ignore"
      }
    }
    bridges = [
      "vmbr0"
    ]
    vm_tags            = ["router", "nginx"]
    template_id        = "192"
    template_tag       = "router"
    started            = true
    onboot             = true
    target_node        = "pve"
    target_node_domain = ""
    dns_servers        = ["8.8.8.8", "8.8.4.4"]
    nics = {
      eth0 = {
        bridges   = "vmbr0"
        addresses = "192.168.1.116/24"
        gateway4  = "192.168.1.1"
        routes = [
          {
            to     = "default"
            via    = "192.168.1.1"
            metric = "10"
          }
        ]
      }
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

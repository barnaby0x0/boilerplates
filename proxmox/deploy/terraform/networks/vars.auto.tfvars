proxmox_connection = {
  proxmox_url = "https://192.168.1.100:8006/api2/json"
  api_token   = "terraform@pve!automation=ccbf32e0-02bd-423e-9030-989e2a47050b"
}

zones = [
  # {
  #   id = "zoneA"
  # },
  # {
  #   id = "zoneB"
  # }
]

vnets = [
  # {
  #   id   = "vneta1"
  #   zone = "zoneA"
  # },
  # {
  #   id   = "vnetb1"
  #   zone = "zoneB"
  # }
]

subnets = [
  # {
  #   cidr    = "10.11.0.0/24"
  #   vnet    = "vneta1"
  #   gateway = "10.11.0.1"
  # },
  # {
  #   cidr    = "10.12.0.0/24"
  #   vnet    = "vnetb1"
  #   gateway = "10.12.0.1"
  # }
]

security_groups = [
  {
    name    = "gitlab-runners"
    comment = "Managed by Terraform"
    rules = [
      {
        type    = "out"
        action  = "ACCEPT"
        comment = "Accept pve node"
        dest    = "192.168.1.100/32"
        log     = "nolog"
      },
      {
        type    = "out"
        action  = "DROP"
        comment = "Block all local network"
        dest    = "192.168.1.0/24"
        log     = "nolog"
      },
      {
        type    = "out"
        action  = "ACCEPT"
        comment = "Allow all external"
        log     = "nolog"
      },
      {
        type    = "in"
        action  = "ACCEPT"
        macro   = "SSH"
        comment = "Allow ssh from rpi router"
        source  = "router-rpi"
        log     = "nolog"
      }
    ]
  },
  {
    name    = "test700"
    comment = "Managed by Terraform"
    rules = [
      {
        type    = "out"
        action  = "ACCEPT"
        comment = "Allow HTTP SERVER"
        dest    = "192.168.1.29"
        dport   = "8080"
        proto   = "tcp"
        log     = "nolog"
      },
      {
        type    = "out"
        action  = "DROP"
        comment = "Block all local network"
        dest    = "192.168.1.0/24"
        log     = "nolog"
        enabled = true
      },
      {
        type    = "out"
        action  = "ACCEPT"
        comment = "Allow all external"
        log     = "nolog"
      },
      {
        type    = "in"
        action  = "ACCEPT"
        macro   = "SSH"
        comment = "Allow ssh from rpi router"
        source  = "router-rpi"
        log     = "nolog"
      },
      {
        type    = "in"
        action  = "ACCEPT"
        macro   = "Ping"
        comment = "Allow ping from rpi router"
        source  = "router-rpi"
        log     = "nolog"
      }      
    ]
  },
  {
    name    = "capgemini"
    comment = "Managed by Terraform"
    rules = [
      {
        type    = "out"
        action  = "DROP"
        comment = "Block all local network"
        dest    = "192.168.1.0/24"
        log     = "nolog"
      },
      {
        type    = "out"
        action  = "ACCEPT"
        comment = "Allow all external"
        log     = "nolog"
      },
      {
        type    = "in"
        action  = "ACCEPT"
        macro   = "SSH"
        comment = "Allow ssh from rpi router"
        source  = "router-rpi"
        log     = "nolog"
      }
    ]
  }
  # {
  #   name    = "dhcp"
  #   comment = "Managed by Terraform"
  #   rules = [
  #     {
  #       type    = "in"
  #       action  = "ACCEPT"
  #       comment = "Allow dhcp upd ports"
  #       proto = "udp"
  #       dport = "67,68"
  #       log     = "nolog"
  #     },
  #           {
  #       type    = "in"
  #       action  = "ACCEPT"
  #       comment = "Allow dhcp upd ports"
  #       proto = "udp"
  #       sport = "68"
  #       dport = "67"
  #       log     = "nolog"
  #     }
  #   ]
  # }
]

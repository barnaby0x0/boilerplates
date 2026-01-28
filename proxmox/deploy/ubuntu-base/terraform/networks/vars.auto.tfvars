proxmox_connection = {
  proxmox_url = "https://192.168.1.100:8006/api2/json"
  api_token   = "terraform@pve!automation=ccbf32e0-02bd-423e-9030-989e2a47050b"
}

zones = [
  {
    id = "zoneA"
  },
  {
    id = "zoneB"
  }
]

vnets = [
  {
    id   = "vneta1"
    zone = "zoneA"
  },
  {
    id   = "vnetb1"
    zone = "zoneB"
  }
]

subnets = [
  {
    cidr    = "10.11.0.0/24"
    vnet    = "vneta1"
    gateway = "10.11.0.1"
  },
  {
    cidr    = "10.12.0.0/24"
    vnet    = "vnetb1"
    gateway = "10.12.0.1"
  }
]
networks = {
  residential = {
    description           = "Residential Services"
    vlan_id               = 10
    cidr                  = "192.168.16.0/24"
    enable_upstream_nat   = true
    additional_nat_source = []
  }
  guest = {
    description           = "Guest Services"
    vlan_id               = 15
    cidr                  = "192.168.17.0/24"
    enable_upstream_nat   = true
    additional_nat_source = []
  }
  services = {
    description           = "Shared Services"
    vlan_id               = 20
    cidr                  = "192.168.18.0/24"
    enable_upstream_nat   = true
    additional_nat_source = []
  }
  iot = {
    description           = "Internet Of Things"
    vlan_id               = 25
    cidr                  = "192.168.19.0/24"
    enable_upstream_nat   = false
    additional_nat_source = []
  }
  telephony = {
    description           = "Telephony Systems"
    vlan_id               = 30
    cidr                  = "192.168.20.0/24"
    enable_upstream_nat   = true
    additional_nat_source = []
  }
  dmz = {
    description           = "DMZ Network"
    vlan_id               = 35
    cidr                  = "192.168.21.0/24"
    enable_upstream_nat   = true
    additional_nat_source = []
  }
  mgmt = {
    description           = "Management Network"
    vlan_id               = 99
    cidr                  = "192.168.31.0/24"
    enable_upstream_nat   = true
    additional_nat_source = []
  }
  peer_internal = {
    description           = "Internal Peering Network"
    vlan_id               = 101
    cidr                  = "169.254.255.0/24"
    enable_upstream_nat   = true
    additional_nat_source = ["192.168.32.0/24"]
  }
}

networks = {
  residential = {
    description         = "Residential Services"
    vlan_id             = 10
    cidr                = "192.168.16.0/24"
    enable_upstream_nat = true
  }
  guest = {
    description         = "Guest Services"
    vlan_id             = 15
    cidr                = "192.168.17.0/24"
    enable_upstream_nat = true
  }
  services = {
    description         = "Shared Services"
    vlan_id             = 20
    cidr                = "192.168.18.0/24"
    enable_upstream_nat = true
  }
  iot = {
    description         = "Internet Of Things"
    vlan_id             = 25
    cidr                = "192.168.19.0/24"
    enable_upstream_nat = false
  }
  telephony = {
    description         = "Telephony Systems"
    vlan_id             = 30
    cidr                = "192.168.20.0/24"
    enable_upstream_nat = true
  }
  dmz = {
    description         = "DMZ Network"
    vlan_id             = 35
    cidr                = "192.168.21.0/24"
    enable_upstream_nat = true
  }
  mgmt = {
    description         = "Management Network"
    vlan_id             = 99
    cidr                = "192.168.31.0/24"
    enable_upstream_nat = true
  }
}

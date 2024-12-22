networks = {
  residential = {
    description        = "Residential Services"
    vlan_id            = 10
    cidr               = "192.168.16.0/24"
    enable_mesh_export = true
    enable_wifi        = true
  }
  guest = {
    description = "Guest Services"
    vlan_id     = 15
    cidr        = "192.168.17.0/24"
    enable_wifi = true
  }
  services = {
    description        = "Shared Services"
    vlan_id            = 20
    cidr               = "192.168.18.0/24"
    enable_mesh_export = true
    bridge_mdns        = true
  }
  iot = {
    description = "Internet Of Things"
    vlan_id     = 25
    cidr        = "192.168.19.0/24"
    enable_wifi = true
    bridge_mdns = true
  }
  telephony = {
    description        = "Telephony Systems"
    vlan_id            = 30
    cidr               = "192.168.20.0/24"
    enable_mesh_export = true
  }
  dmz = {
    description        = "DMZ Network"
    vlan_id            = 35
    cidr               = "192.168.21.0/24"
    enable_mesh_export = true
  }
  mgmt = {
    description = "Management Network"
    vlan_id     = 99
    cidr        = "192.168.31.0/24"
  }
  peer_internal = {
    description = "Internal Peering Network"
    vlan_id     = 101
    cidr        = "169.254.255.0/24"
    additional_nat_source = [
      "192.168.32.0/24",
      "172.16.29.0/24",
      "172.16.30.0/24",
      "172.16.31.0/24",
      "172.16.34.0/24",
      "100.64.0.0/24",
    ]
  }
}

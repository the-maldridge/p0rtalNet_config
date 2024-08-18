data "routeros_interfaces" "ether1" {
  filter = {
    name = "ether1"
  }
}

resource "routeros_interface_bridge" "br0" {
  name           = "br0"
  vlan_filtering = true
  frame_types    = "admit-only-vlan-tagged"
  auto_mac       = false
  admin_mac      = data.routeros_interfaces.ether1.interfaces[0].mac_address
}

resource "routeros_interface_vlan" "uplink" {
  name      = "uplink0"
  interface = routeros_interface_bridge.br0.name
  vlan_id   = 1
  comment   = "Untagged Uplink Network"
}

resource "routeros_interface_bridge_vlan" "br_uplink" {
  bridge   = routeros_interface_bridge.br0.name
  vlan_ids = [routeros_interface_vlan.uplink.vlan_id]
  tagged   = [routeros_interface_bridge.br0.name]
  untagged = ["ether1"]
}

resource "routeros_interface_bridge_vlan" "br_vlan" {
  bridge   = routeros_interface_bridge.br0.name
  vlan_ids = [for id, net in var.networks : net.vlan_id if(net.enable_wifi || id == "mgmt")]
  tagged   = ["ether1", routeros_interface_bridge.br0.name]
}

resource "routeros_interface_bridge_port" "uplink" {
  bridge    = routeros_interface_bridge.br0.name
  interface = "ether1"
  pvid      = 1
  disabled  = var.bootstrap
}

resource "routeros_ip_dhcp_client" "upstream" {
  interface         = routeros_interface_vlan.uplink.name
  add_default_route = "yes"
  use_peer_ntp      = true
  use_peer_dns      = true
  script            = "{/ip/dhcp-client/set 0 disabled=yes}"
  comment           = "Internal Upstream"
}

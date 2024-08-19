data "routeros_interfaces" "sfp1" {
  filter = {
    name = "sfp1"
  }
}

resource "routeros_interface_bridge" "br0" {
  name              = "br0"
  frame_types       = "admit-only-vlan-tagged"
  vlan_filtering    = true
  ingress_filtering = true
  auto_mac          = false
  admin_mac         = data.routeros_interfaces.sfp1.interfaces[0].mac_address
}

resource "routeros_interface_vlan" "lan" {
  name      = "lan0"
  interface = routeros_interface_bridge.br0.name
  vlan_id   = 20
  comment   = "LAN"
}

resource "routeros_interface_bridge_vlan" "br_internal" {
  bridge   = routeros_interface_bridge.br0.name
  vlan_ids = [routeros_interface_vlan.lan.vlan_id]
  tagged   = [routeros_interface_bridge.br0.name]
  untagged = flatten([formatlist("ether%s", [1, 2, 3, 4, 5]), "sfp1"])
}

resource "routeros_interface_bridge_port" "ports" {
  for_each = toset(formatlist("ether%s", [1, 2, 3, 4, 5]))

  bridge    = routeros_interface_bridge.br0.name
  interface = each.key
  pvid      = 20
}

resource "routeros_interface_bridge_port" "sfp" {
  bridge    = routeros_interface_bridge.br0.name
  interface = "sfp1"
  pvid      = 20
  disabled  = var.bootstrap
}

resource "routeros_ip_dhcp_client" "upstream" {
  interface         = routeros_interface_vlan.lan.name
  add_default_route = "yes"
  use_peer_ntp      = true
  use_peer_dns      = true
  script            = "{/ip/dhcp-client/set 0 disabled=yes}"
  comment           = "Internal Upstream"
}

resource "routeros_interface_bridge" "br0" {
  name              = "br0"
  vlan_filtering    = true
  frame_types       = "admit-only-vlan-tagged"
  ingress_filtering = true
}

resource "routeros_interface_vlan" "lan" {
  interface = routeros_interface_bridge.br0.name
  name      = "lan0"
  vlan_id   = 20
}

resource "routeros_interface_vlan" "wan" {
  interface = routeros_interface_bridge.br0.name
  name      = "wan0"
  vlan_id   = 30
}

resource "routeros_interface_bridge_vlan" "br_vlan" {
  bridge = routeros_interface_bridge.br0.name
  vlan_ids = [
    routeros_interface_vlan.lan.vlan_id,
    routeros_interface_vlan.wan.vlan_id,
  ]
  tagged = [routeros_interface_bridge.br0.name]
}

resource "routeros_ip_address" "lan0" {
  address   = format("%s/%s", cidrhost(var.main_subnet, 1), split("/", var.main_subnet)[1])
  interface = routeros_interface_vlan.lan.name
}

resource "routeros_ip_dhcp_client" "wan0" {
  interface         = routeros_interface_vlan.wan.name
  add_default_route = "yes"
  use_peer_dns      = false
  use_peer_ntp      = false
}

resource "routeros_ip_firewall_addr_list" "local_nets" {
  list    = "local-nets"
  address = var.main_subnet
}

resource "routeros_ip_firewall_addr_list" "accept_remote" {
  for_each = var.inbound_subnets

  list    = "accept-remote"
  address = each.key
}

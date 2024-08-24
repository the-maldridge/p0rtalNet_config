resource "routeros_interface_bridge_port" "ether1" {
  bridge    = routeros_interface_bridge.br0.name
  interface = "ether1"
  pvid      = routeros_interface_vlan.wan.vlan_id
}

resource "routeros_interface_bridge_port" "local" {
  for_each = toset(["ether2", "ether3", "ether4", "ether5"])

  bridge    = routeros_interface_bridge.br0.name
  interface = each.key
  pvid      = routeros_interface_vlan.lan.vlan_id
}

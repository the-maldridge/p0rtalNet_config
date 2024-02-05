locals {
  switch_vlan_ids = flatten([[for net in var.networks : net.vlan_id], 110, 111])
}

resource "routeros_interface_bonding" "bond0" {
  name    = "bond0"
  slaves  = ["ether3", "ether4"]
  mode    = "802.3ad"
  comment = "Core Switch Link"
}

resource "routeros_interface_bridge_port" "bond0" {
  bridge    = routeros_interface_bridge.br0.name
  interface = routeros_interface_bonding.bond0.name
  pvid      = 1
  comment   = "Core Switch"
}

resource "routeros_interface_bridge_vlan" "bond0" {
  bridge   = routeros_interface_bridge.br0.name
  vlan_ids = join(",", local.switch_vlan_ids)
  tagged   = [routeros_interface_bonding.bond0.name]
  comment  = "Core Switch Trunks"
}

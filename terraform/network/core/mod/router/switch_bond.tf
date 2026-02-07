locals {
  bonds = {
    bond0 = {
      comment = "Core Switch"
      members = formatlist("sfp-sfpplus%d", [11, 12])
    }

    bond1 = {
      comment = "MPOE"
      members = formatlist("sfp-sfpplus%d", [9, 10])
    }

    bond2 = {
      comment = "Compute Rack"
      members = formatlist("sfp-sfpplus%d", [7, 8])
    }
  }
  switch_vlan_ids = flatten([[for net in var.networks : net.vlan_id], 110, 111])
}

resource "routeros_interface_bonding" "bond" {
  for_each = local.bonds

  name    = each.key
  slaves  = each.value.members
  mode    = "802.3ad"
  comment = each.value.comment
}

resource "routeros_interface_bridge_port" "bond" {
  for_each = local.bonds

  bridge    = routeros_interface_bridge.br0.name
  interface = each.key
  pvid      = 1
  comment   = each.value.comment
}

resource "routeros_interface_bridge_port" "ether1" {
  bridge    = routeros_interface_bridge.br0.name
  interface = "ether1"
  pvid      = 99
  comment   = "Management Port"
}

resource "routeros_interface_bridge_port" "peers" {
  for_each = toset(formatlist("sfp-sfpplus%d", [4, 5, 6]))

  bridge    = routeros_interface_bridge.br0.name
  interface = each.key
  pvid      = 101
  comment   = "Peering Port"
}

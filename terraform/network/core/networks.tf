resource "routeros_interface_list" "lan" {
  name    = "LAN"
  comment = "Local Interfaces"
}

resource "routeros_interface_list_member" "lan" {
  for_each = var.networks

  interface = routeros_interface_vlan.vlan[each.key].name
  list      = routeros_interface_list.lan.name
}

resource "routeros_interface_bridge" "br0" {
  name           = "br0"
  vlan_filtering = true
  frame_types    = "admit-only-vlan-tagged"
}

resource "routeros_interface_bridge_vlan" "br_vlan" {
  bridge   = routeros_interface_bridge.br0.name
  vlan_ids = flatten([[for net in var.networks : net.vlan_id], 110, 111])
  tagged   = [routeros_interface_bridge.br0.name]
}

resource "routeros_interface_vlan" "vlan" {
  for_each = var.networks

  interface = routeros_interface_bridge.br0.name
  name      = each.key
  comment   = each.value.description
  vlan_id   = each.value.vlan_id
}

resource "routeros_interface_bridge_port" "vlan" {
  for_each = var.networks

  interface = routeros_interface_vlan.vlan[each.key].name
  pvid      = each.value.vlan_id
  bridge    = routeros_interface_bridge.br0.name
}

resource "routeros_ip_address" "addr" {
  for_each = var.networks

  address   = format("%s/%s", cidrhost(each.value.cidr, 1), split("/", each.value.cidr)[1])
  interface = routeros_interface_vlan.vlan[each.key].name
}

resource "routeros_ip_firewall_addr_list" "nat_sources" {
  for_each = { for net, data in var.networks : net => data if lookup(data, "enable_upstream_nat", false) }

  list    = "internet_enabled"
  address = each.value.cidr
  comment = format("Primary NAT for %s", each.value.description)
}

resource "routeros_ip_firewall_addr_list" "nat_sources_secondary" {
  for_each = { for i in flatten([
    for net, data in var.networks : [
      for sup in data.additional_nat_source : { cidr = sup, description = data.description, net = net }
    ]
  ]) : i.cidr => i }

  list    = "internet_enabled"
  address = each.value.cidr
  comment = format("Supplemental NAT for %s", each.value.description)
}

resource "routeros_ip_firewall_addr_list" "mesh_exports" {
  for_each = { for net, data in var.networks : net => data if lookup(data, "enable_mesh_export", false) }

  list    = "mesh_enabled"
  address = each.value.cidr
  comment = format("Mesh Export: %s", each.key)
}

locals {
  upstreams = {
    "frontier" : { link = 110, distance = 100 },
    "spectrum" : { link = 111, distance = 120 },
  }
}

resource "routeros_interface_list" "wan" {
  name    = "WAN"
  comment = "Upstream Internet Providers"
}

resource "routeros_interface_vlan" "upstream" {
  for_each = local.upstreams

  interface = routeros_interface_bridge.br0.name
  name      = format("%s0", each.key)
  comment   = title(format("External %s Internet", each.key))
  vlan_id   = each.value.link
}

resource "routeros_ip_dhcp_client" "upstream" {
  for_each = local.upstreams

  interface              = routeros_interface_vlan.upstream[each.key].name
  add_default_route      = "yes"
  default_route_distance = each.value.distance
  use_peer_dns           = false
  use_peer_ntp           = false
}

resource "routeros_interface_bridge_port" "upstream" {
  for_each = local.upstreams

  interface = routeros_interface_vlan.upstream[each.key].name
  bridge    = routeros_interface_bridge.br0.name
  pvid      = each.value.link
}

resource "routeros_interface_list_member" "upstream" {
  for_each = local.upstreams

  interface = routeros_interface_vlan.upstream[each.key].name
  list      = routeros_interface_list.wan.name
}

resource "routeros_interface_bridge_vlan" "upstream_vlan" {
  for_each = routeros_interface_vlan.upstream

  comment  = each.value.comment
  bridge   = routeros_interface_bridge.br0.name
  vlan_ids = [tonumber(each.value.vlan_id)]
  tagged = flatten([
    routeros_interface_bridge.br0.name,
    routeros_interface_bonding.bond0.name,
    routeros_interface_bonding.bond1.name,
  ])
}

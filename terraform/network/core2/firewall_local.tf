resource "routeros_ip_firewall_filter" "zonal_flows" {
  for_each = { for i in [
    { src = "dmz", dst = "mgmt" },
    { src = "dmz", dst = "residential" },
    { src = "mgmt", dst = "services" },
    { src = "peer_internal", dst = "dmz" },
    { src = "peer_internal", dst = "telephony" },
    { src = "residential", dst = "dmz" },
    { src = "residential", dst = "iot" },
    { src = "residential", dst = "peer_internal" },
    { src = "residential", dst = "services" },
    { src = "residential", dst = "telephony" },
    { src = "services", dst = "iot" },
    { src = "telephony", dst = "peer_internal" },
  ] : format("%s-to-%s", i.src, i.dst) => i }

  chain         = "forward"
  action        = "accept"
  comment       = each.key
  in_interface  = routeros_interface_vlan.vlan[each.value.src].name
  out_interface = routeros_interface_vlan.vlan[each.value.dst].name
  place_before  = routeros_ip_firewall_filter.drop_forward_default.id
}

resource "routeros_ip_firewall_filter" "to_mesh" {
  chain              = "forward"
  action             = "accept"
  comment            = "lan-to-mesh"
  in_interface_list  = routeros_interface_list.lan.name
  out_interface_list = routeros_interface_list.mesh_peer.name
  place_before       = routeros_ip_firewall_filter.drop_forward_default.id
}

resource "routeros_ip_firewall_filter" "mesh_to_mesh" {
  chain              = "forward"
  action             = "accept"
  comment            = "mesh-to-mesh"
  in_interface_list  = routeros_interface_list.mesh_peer.name
  out_interface_list = routeros_interface_list.mesh_peer.name
  place_before       = routeros_ip_firewall_filter.drop_forward_default.id
}

resource "routeros_ip_firewall_nat" "inbound_portmap" {
  for_each = {
    basion_ssh = { port = 22, proto = "tcp", target = "192.168.21.5" },
  }

  chain             = "dstnat"
  action            = "dst-nat"
  comment           = each.key
  protocol          = each.value.proto
  dst_port          = each.value.port
  to_addresses      = each.value.target
  in_interface_list = routeros_interface_list.wan.name
}

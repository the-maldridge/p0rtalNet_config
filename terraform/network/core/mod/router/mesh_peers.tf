resource "routeros_interface_list" "mesh_peer" {
  name    = "MESH"
  comment = "Mesh Peers"
}

resource "routeros_interface_list_member" "mesh_peer" {
  for_each = var.bgp_peers

  interface = routeros_interface_wireguard.peer[each.key].name
  list      = routeros_interface_list.mesh_peer.name
}

resource "routeros_interface_wireguard" "peer" {
  for_each = var.bgp_peers

  name        = each.key
  listen_port = each.value.listen
  private_key = each.value.privkey
  comment     = format("peer-%s", each.key)
}

resource "routeros_interface_wireguard_peer" "peer" {
  for_each = var.bgp_peers

  interface       = routeros_interface_wireguard.peer[each.key].name
  public_key      = each.value.pubkey
  allowed_address = ["0.0.0.0/0"]

  endpoint_address     = try(split(":", each.value.endpoint)[0], "")
  endpoint_port        = try(split(":", each.value.endpoint)[1], 0)
  persistent_keepalive = "30s"
}

resource "routeros_ip_address" "peer" {
  for_each = var.bgp_peers

  interface = routeros_interface_wireguard.peer[each.key].name
  address   = each.value.local_addr
}

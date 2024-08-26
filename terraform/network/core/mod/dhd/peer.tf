resource "routeros_interface_list" "peers" {
  name    = "peers"
  comment = "BGP Peers"
}

resource "routeros_interface_list_member" "peer" {
  for_each = var.peer_config

  interface = routeros_interface_wireguard.peer[each.key].name
  list      = routeros_interface_list.peers.name
}

resource "routeros_ip_firewall_addr_list" "accept_peer" {
  for_each = var.peer_config

  list    = "accept-remote"
  address = split("/", each.value.addr)[0]
}

resource "routeros_interface_wireguard" "peer" {
  for_each = var.peer_config

  name        = each.key
  listen_port = each.value.listen
  private_key = each.value.privkey
}

resource "routeros_interface_wireguard_peer" "peer" {
  for_each = var.peer_config

  name                 = each.key
  interface            = routeros_interface_wireguard.peer[each.key].name
  public_key           = each.value.pubkey
  allowed_address      = ["0.0.0.0/0"]
  endpoint_address     = try(split(":", each.value.endpoint)[0], "")
  endpoint_port        = try(split(":", each.value.endpoint)[1], "")
  persistent_keepalive = "30s"
}

resource "routeros_ip_address" "peer" {
  for_each = var.peer_config

  interface = routeros_interface_wireguard.peer[each.key].name
  address   = each.value.local_addr
}

resource "routeros_routing_filter_rule" "import" {
  chain   = "restricted-import"
  rule    = "if (dst in ${var.main_subnet}) {reject} else {accept}"
  comment = "Reject overlapping subnets"
}

resource "routeros_routing_bgp_connection" "peer" {
  for_each = var.peer_config

  as   = 64580
  name = each.key

  connect = true
  listen  = true

  router_id = cidrhost(var.main_subnet, 1)

  hold_time      = "30s"
  keepalive_time = "10s"

  local {
    role    = "ebgp"
    address = split("/", each.value.local_addr)[0]
  }

  remote {
    address = split("/", each.value.addr)[0]
    as      = each.value.as
  }

  input {
    filter = "restricted-import"
  }

  output {
    network           = "local-nets"
    default_originate = "if-installed"
    redistribute      = "connected"
  }
}

resource "routeros_routing_bgp_connection" "gate" {
  as   = 64580
  name = "stargate"

  connect = true
  listen  = true

  router_id = cidrhost(var.main_subnet, 1)

  hold_time      = "30s"
  keepalive_time = "10s"

  local {
    role    = "ebgp"
    address = "169.254.250.1"
  }

  remote {
    address = "169.254.250.2"
  }

  input {
    filter = "restricted-import"
  }

  output {
    network           = "local-nets"
    default_originate = "if-installed"
    redistribute      = "connected"
  }
}

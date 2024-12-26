resource "routeros_ip_firewall_addr_list" "accept_peer" {
  list    = "accept-remote"
  address = split("/", var.peer_config.addr)[0]
}

resource "routeros_interface_wireguard" "peer" {
  name        = "peer0"
  listen_port = var.peer_config.listen
  private_key = var.peer_config.privkey
}

resource "routeros_interface_wireguard_peer" "peer" {
  name                 = "p0rtalNet"
  interface            = routeros_interface_wireguard.peer.name
  public_key           = var.peer_config.pubkey
  allowed_address      = ["0.0.0.0/0"]
  endpoint_address     = try(split(":", var.peer_config.endpoint)[0], "")
  endpoint_port        = try(split(":", var.peer_config.endpoint)[1], "")
  persistent_keepalive = "30s"
}

resource "routeros_ip_address" "peer" {
  interface = routeros_interface_wireguard.peer.name
  address   = var.peer_config.local_addr
}

resource "routeros_routing_filter_rule" "import" {
  chain   = "p0rtalNet-import"
  rule    = "if (dst in 192.168.16.0/20) { accept } else { reject }"
  comment = "Only accept known origins"
}

resource "routeros_routing_bgp_connection" "peer" {
  as   = var.peer_config.as
  name = "p0rtalNet"

  connect = true
  listen  = true

  router_id = split("/", var.peer_config.local_addr)[0]

  hold_time      = "30s"
  keepalive_time = "10s"

  local {
    role    = "ebgp"
    address = split("/", var.peer_config.local_addr)[0]
  }

  remote {
    address = split("/", var.peer_config.addr)[0]
  }

  input {
    filter = "p0rtalNet-import"
  }

  output {
    network = "local-nets"
  }
}

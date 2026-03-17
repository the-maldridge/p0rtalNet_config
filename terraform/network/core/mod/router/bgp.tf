resource "routeros_routing_bgp_instance" "internal" {
  as         = 64579
  name       = "Internal"
  comment    = "Internal Peers"
  cluster_id = "169.254.255.1"
  router_id  = "169.254.255.1"
}

resource "routeros_routing_bgp_connection" "internal" {
  for_each = {
    minicluster = "169.254.255.2"
  }

  as       = 64579
  name     = each.key
  instance = routeros_routing_bgp_instance.internal.name

  connect        = true
  listen         = true
  nexthop_choice = "force-self"

  hold_time      = "30s"
  keepalive_time = "10s"

  local {
    role    = "ibgp"
    address = "169.254.255.1"
  }

  remote {
    address = each.value
  }

  output {
    default_originate = "if-installed"
    redistribute      = "connected"
  }
}

resource "routeros_routing_bgp_instance" "sneakynet" {
  as         = 64579
  name       = "SneakyNet"
  comment    = "SneakyNet Peers"
  cluster_id = "169.254.255.1"
  router_id  = "169.254.255.1"
}

resource "routeros_routing_bgp_connection" "sneakynet" {
  for_each = {
    bag-bcm   = "169.254.255.4"
    sneakynet = "169.254.255.6"
    minitel   = "169.254.255.7"
    net-a     = "169.254.255.8"
    net-b     = "169.254.255.5"
    net-c     = "169.254.255.9"
  }

  as       = 64579
  name     = each.key
  instance = routeros_routing_bgp_instance.sneakynet.name

  connect        = true
  listen         = true
  nexthop_choice = "force-self"

  hold_time      = "30s"
  keepalive_time = "10s"

  local {
    role    = "ebgp"
    address = "169.254.255.1"
  }

  remote {
    address = each.value
    as      = 64582
  }

  input {
    filter = "mesh-import"
  }

  output {
    default_originate = "if-installed"
    redistribute      = "connected"
  }
}

resource "routeros_routing_filter_rule" "mesh_imports" {
  chain   = "mesh-import"
  rule    = "if (dst in 192.168.16.0/20 || dst-len < 15) {reject} else {accept}"
  comment = "Do not accept harmful routes."
}

resource "routeros_routing_bgp_instance" "mesh" {
  as         = 64579
  name       = "Mesh"
  comment    = "Mesh Peers"
  cluster_id = "169.254.255.1"
  router_id  = "169.254.255.1"
}

resource "routeros_routing_bgp_connection" "peer" {
  for_each = var.bgp_peers

  as       = 64579
  name     = each.key
  instance = routeros_routing_bgp_instance.mesh.name

  disabled = !lookup(each.value, "bgp", true)

  connect = true
  listen  = true

  hold_time      = "30s"
  keepalive_time = "10s"

  local {
    role    = "ebgp"
    address = split("/", each.value.local_addr)[0]
  }

  remote {
    address = cidrhost(each.value.addr, 0)
  }

  input {
    filter = "mesh-import"
  }

  output {
    network = "mesh_enabled"
  }
}

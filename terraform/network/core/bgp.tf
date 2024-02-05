resource "routeros_routing_bgp_connection" "internal" {
  for_each = {
    minicluster = "169.254.255.2"
    bag-bcm     = "169.254.255.4"
    bag-net     = "169.254.255.5"
    sneakynet   = "169.254.255.6"
    minitel     = "169.254.255.7"
  }

  as   = 64579
  name = each.key

  connect = true
  listen  = true

  cluster_id = "169.254.255.1"
  router_id  = "169.254.255.1"

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

resource "routeros_routing_filter_rule" "mesh_import_no_overlap" {
  chain   = "mesh-import"
  rule    = "if (dst in 192.168.16.0/20) {reject}"
  comment = "Do not accept overlapped prefixes"
}

resource "routeros_routing_filter_rule" "mesh_import_no_hugeprefix" {
  chain   = "mesh-import"
  rule    = "if (dst-len < 15) {reject}"
  comment = "Do not accept huge prefixes"
}

resource "routeros_routing_bgp_connection" "peer" {
  for_each = var.bgp_peers

  as   = 64579
  name = each.key

  disabled = !lookup(each.value, "bgp", true)

  connect = true
  listen  = true

  router_id = "169.254.255.1"

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

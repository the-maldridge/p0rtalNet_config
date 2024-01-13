resource "routeros_routing_bgp_connection" "core" {
  as   = 64579
  name = "core"

  connect = true
  listen  = true

  cluster_id = "169.254.255.1"
  router_id  = "169.254.255.3"

  local {
    role    = "ibgp"
    address = "169.254.255.3"
  }

  remote {
    address = "169.254.255.1"
  }
}

resource "routeros_routing_filter_rule" "mesh_export" {
  chain   = "mesh-export"
  rule    = "if (dst in 192.168.16.0/20) {accept} else {reject}"
  comment = "Use Specified Exports"
}

resource "routeros_routing_filter_rule" "mesh_import_no_overlap" {
  chain   = "mesh-import"
  rule    = "if (dst in 192.168.16.0/20) {reject} else {accept}"
  comment = "Do not accept overlapped prefixes"
}

resource "routeros_routing_filter_rule" "mesh_import_no_hugeprefix" {
  chain   = "mesh-import"
  rule    = "if (dst-len < 15) {reject} else {accept}"
  comment = "Do not accept huge prefixes"
}

resource "routeros_routing_bgp_connection" "peer" {
  for_each = var.bgp_peers

  as   = 64579
  name = each.key

  disabled = !lookup(each.value, "bgp", true)

  connect = true
  listen  = true

  router_id = "169.254.255.3"

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
    filter_chain = "mesh-export"
  }
}

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

resource "routeros_routing_bgp_connection" "peer" {
  for_each = { for k, v in var.bgp_peers : k => v if v.bgp }

  as   = 64579
  name = each.key

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

}

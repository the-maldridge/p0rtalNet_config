resource "routeros_ip_pool" "pool" {
  for_each = var.networks

  name    = each.key
  ranges  = ["${cidrhost(each.value.cidr, 3)}-${cidrhost(each.value.cidr, 100)}"]
  comment = each.value.description
}

resource "routeros_ip_dhcp_server" "server" {
  for_each = var.networks

  interface          = routeros_interface_vlan.vlan[each.key].name
  name               = each.key
  address_pool       = routeros_ip_pool.pool[each.key].name
  comment            = each.value.description
  conflict_detection = true
  lease_time         = "1h"
}

resource "routeros_ip_dhcp_server_network" "network" {
  for_each = var.networks

  address    = each.value.cidr
  comment    = "Options for ${each.value.description}"
  gateway    = cidrhost(each.value.cidr, 1)
  domain     = "dal.michaelwashere.net"
  dns_server = [cidrhost(each.value.cidr, 1)]
}

resource "routeros_ip_dhcp_server_lease" "static_lease" {
  for_each = var.reserved_addresses

  address     = each.value.addr
  mac_address = each.value.mac
  comment     = each.key
  server      = routeros_ip_dhcp_server.server[each.value.net].name
}

resource "routeros_ip_dns_record" "static_hosts" {
  for_each = var.reserved_addresses

  name    = format("%s.dal.michaelwashere.net", each.key)
  address = each.value.addr
  type    = "A"
}

resource "routeros_ip_dns_record" "static_cnames" {
  for_each = merge([for host, data in var.reserved_addresses : { for cname in data.cname : cname => host } if length(data.cname) > 0]...)

  name  = endswith(each.key, ".") ? trimsuffix(each.key, ".") : format("%s.%s", each.key, "dal.michaelwashere.net")
  type  = "CNAME"
  cname = format("%s.%s", each.value, "dal.michaelwashere.net")
}

resource "routeros_ip_dns_record" "self_dns" {
  name    = "edge01.dal.michaelwashere.net"
  address = "192.168.31.1"
  type    = "A"
}

# This record exists so that devices across the network can poll for
# it to determine if the network is available yet.  The idea here is
# to sort out the boot-time races that occur when Runit comes up.
resource "routeros_ip_dns_record" "net_available" {
  name    = "net-available.dal.michaelwashere.net"
  address = "127.0.0.1"
  type    = "A"
}

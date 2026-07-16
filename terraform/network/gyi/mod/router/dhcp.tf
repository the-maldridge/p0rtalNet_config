resource "routeros_ip_pool" "pool" {
  name   = "pool"
  ranges = ["${cidrhost(var.main_subnet, 3)}-${cidrhost(var.main_subnet, 100)}"]
}

resource "routeros_ip_dhcp_server" "lan" {
  interface          = routeros_interface_vlan.lan.name
  name               = "LAN"
  address_pool       = routeros_ip_pool.pool.name
  conflict_detection = true
  lease_time         = "1h"

  dynamic_lease_identifiers = "client-mac,client-id"
}

resource "routeros_ip_dhcp_server_network" "network" {
  address    = var.main_subnet
  gateway    = cidrhost(var.main_subnet, 1)
  domain     = var.domain
  dns_server = [cidrhost(var.main_subnet, 1)]
}

resource "routeros_ip_pool" "guest" {
  name   = "guest"
  ranges = ["${cidrhost(var.guest_subnet, 3)}-${cidrhost(var.guest_subnet, 100)}"]
}

resource "routeros_ip_dhcp_server" "guest" {
  interface          = routeros_interface_vlan.guest.name
  name               = "GUEST"
  address_pool       = routeros_ip_pool.guest.name
  conflict_detection = true
  lease_time         = "1h"

  dynamic_lease_identifiers = "client-mac,client-id"
}

resource "routeros_ip_dhcp_server_network" "guest" {
  address    = var.guest_subnet
  gateway    = cidrhost(var.guest_subnet, 1)
  domain     = var.domain
  dns_server = [cidrhost(var.guest_subnet, 1)]
}

resource "routeros_ip_dhcp_server_lease" "static_lease" {
  for_each = var.reserved_addresses

  address     = each.value.addr
  mac_address = each.value.mac
  comment     = each.key
  server      = routeros_ip_dhcp_server.lan.name
}

resource "routeros_ip_dns_record" "static_hosts" {
  for_each = var.reserved_addresses

  name    = format("%s.%s", each.key, var.domain)
  address = each.value.addr
  type    = "A"
}

resource "routeros_ip_dns_record" "self_dns" {
  name    = "edge01.${var.domain}"
  address = cidrhost(var.main_subnet, 1)
  type    = "A"
}

# This record exists so that devices across the network can poll for
# it to determine if the network is available yet.  The idea here is
# to sort out the boot-time races that occur when Runit comes up.
resource "routeros_ip_dns_record" "net_available" {
  name    = "net-available.${var.domain}"
  address = "127.0.0.1"
  type    = "A"
}

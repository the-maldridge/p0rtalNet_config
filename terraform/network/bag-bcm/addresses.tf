resource "junos_security_address_book" "local_addresses" {
  name        = "local-addresses"
  attach_zone = [junos_security_zone.local.name]
}

resource "junos_security_address_book" "peer_addresses" {
  name = "peer-addresses"

  attach_zone = [junos_security_zone.peer.name]

  network_address {
    name        = "resnet"
    description = "Internal Residential Address Space"
    value       = "192.168.16.0/24"
  }

  network_address {
    name        = "p0rtalNet_core"
    description = "Core Router Peer"
    value       = "169.254.255.1/32"
  }
}
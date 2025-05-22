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

  network_address {
    name        = "p0rtalNet_telephony"
    description = "Static Telephony Services"
    value       = "192.168.20.0/24"
  }

  network_address {
    name        = "net-a"
    description = "Network Rack A"
    value       = "172.16.34.0/24"
  }

  network_address {
    name        = "sneakynet-bag"
    description = "SneakyNet Bag Router"
    value       = "172.16.31.0/24"
  }

  network_address {
    name        = "sneakynet-rack"
    description = "SneakyNet Services Rack"
    value       = "172.16.29.0/24"
  }

  network_address {
    name        = "vofr-oam"
    description = "VoFR OAM Services"
    value       = "172.31.0.0/24"
  }
}

resource "junos_security_address_book" "cluster_addresses" {
  name        = "cluster-addresses"
  attach_zone = [junos_security_zone.cluster.name]

  network_address {
    name        = "bootmaster"
    description = "Address of the bootmaster"
    value       = "192.168.32.2/32"
  }

  network_address {
    name        = "node1"
    description = "Address of the head node"
    value       = "192.168.32.10/32"
  }
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

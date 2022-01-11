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

resource "junos_security_zone" "peer" {
  name = "peering"

  inbound_services = ["bgp"]
}

resource "junos_vlan" "peer" {
  name        = "vlan-peer"
  description = "Peering fabric"
  vlan_id     = 101

  l3_interface = junos_interface_logical.peer_vlan.name
}

resource "junos_interface_logical" "peer_vlan" {
  depends_on = [junos_security_zone.peer]

  name          = "vlan.101"
  description   = "Peering Network IRB"
  security_zone = junos_security_zone.peer.name

  family_inet {
    address {
      cidr_ip = "169.254.255.2/24"
    }
  }
}

resource "junos_interface_logical" "peer_port" {
  name          = "ge-0/0/7.0"
  description   = "Router Peer Port"
  security_zone = junos_security_zone.peer.name
}

resource "junos_interface_physical" "peer_port" {
  name        = "ge0/0/7"
  description = "Router Peer Port"

  vlan_members = [junos_vlan.peer.name]
}

resource "junos_security_policy" "accept_from_peer" {
  depends_on = [junos_security_address_book.peer_addresses]

  from_zone = junos_security_zone.peer.name
  to_zone   = junos_security_zone.cluster.name

  policy {
    name                      = "extres-to-cluster"
    match_source_address      = ["resnet"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

resource "junos_security_policy" "permit_to_peer" {
  depends_on = [junos_security_address_book.peer_addresses]

  from_zone = junos_security_zone.cluster.name
  to_zone   = junos_security_zone.peer.name

  policy {
    name                      = "permit-upstream-to-peer"
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

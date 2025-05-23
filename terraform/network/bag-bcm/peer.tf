resource "junos_security_zone" "peer" {
  name = "peering"
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
      cidr_ip = "169.254.255.4/24"
    }
  }
}

resource "junos_interface_physical" "peer_port" {
  for_each = toset(["1", "2", "3"])

  name        = format("ge-0/0/%d", each.key)
  description = "Router Peer Port"

  vlan_members = [junos_vlan.peer.name]
}

resource "junos_security_policy" "accept_from_peer" {
  depends_on = [junos_security_address_book.peer_addresses]

  from_zone = junos_security_zone.peer.name
  to_zone   = junos_security_zone.local.name

  policy {
    name                      = "extres-to-local"
    match_source_address      = ["resnet", "p0rtalNet_telephony", "vofr-oam"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }

  policy {
    name                      = "sneakynet-to-local"
    match_source_address      = ["sneakynet-bag", "sneakynet-rack", "net-a"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

resource "junos_security_policy" "permit_to_peer" {
  depends_on = [junos_security_address_book.peer_addresses]

  from_zone = junos_security_zone.local.name
  to_zone   = junos_security_zone.peer.name

  policy {
    name                      = "permit-upstream-to-peer"
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

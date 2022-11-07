resource "junos_security_address_book" "dmz_addresses" {
  name        = "dmz-addresses"
  attach_zone = [junos_security_zone.zone["dmz"].name]

  network_address {
    name        = "ssh-bastion"
    description = "SSH Bastion Host"
    value       = "192.168.21.5/32"
  }

  network_address {
    name        = "minecraft"
    description = "Minecraft Service"
    value       = "192.168.21.6/32"
  }
}

resource "junos_security_address_book" "peer_addresses" {
  name        = "peer-addresses"
  attach_zone = [junos_security_zone.zone["peer_internal"].name]

  network_address {
    name        = "minicluster"
    description = "minicluster subnet"
    value       = "192.168.32.0/24"
  }

  network_address {
    name        = "mesh1edge1"
    description = "mesh1edge1 peering router"
    value       = "169.254.255.3/32"
  }
}

resource "junos_security_address_book" "telephony_addresses" {
  name        = "telephony-addresses"
  attach_zone = [junos_security_zone.zone["telephony"].name]

  network_address {
    name        = "DLLSTXPO01DS0"
    description = "BCM50"
    value       = "192.168.20.5/32"
  }
  network_address {
    name        = "DLLSTXPO01T"
    description = "Tandem"
    value       = "192.168.20.4/32"
  }
}

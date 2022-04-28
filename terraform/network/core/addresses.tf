resource "junos_security_address_book" "dmz_addresses" {
  name        = "dmz-addresses"
  attach_zone = [junos_security_zone.zone["dmz"].name]

  network_address {
    name        = "ssh-bastion"
    description = "SSH Bastion Host"
    value       = "192.168.21.5/32"
  }
}

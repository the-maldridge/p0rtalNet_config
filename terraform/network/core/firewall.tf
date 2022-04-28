resource "junos_security_nat_destination_pool" "dmz_bastion" {
  name    = "dmz-bastion"
  address = "192.168.21.5/32"
}

resource "junos_security_nat_destination" "inbound_dnat" {
  name = "inbound-dnat"

  from {
    type  = "zone"
    value = ["upstream"]
  }

  rule {
    name                = "bastion-ssh"
    destination_address = "0.0.0.0/0"
    destination_port    = ["22"]
    then {
      type = "pool"
      pool = junos_security_nat_destination_pool.dmz_bastion.name
    }
  }
}

resource "junos_security_policy" "inbound_svcs" {
  depends_on = [junos_security_address_book.dmz_addresses]

  from_zone = "upstream"
  to_zone   = junos_security_zone.zone["dmz"].name

  policy {
    name                      = "bastion-ssh"
    match_source_address      = ["any"]
    match_destination_address = ["ssh-bastion"]
    match_application         = [junos_application.ssh.name]
  }
}

resource "junos_security_policy" "dmz_to_mgmt" {
  depends_on = [junos_security_address_book.dmz_addresses]

  from_zone = junos_security_zone.zone["dmz"].name
  to_zone   = junos_security_zone.zone["mgmt"].name

  policy {
    name                      = "bastion-to-mgmt"
    match_source_address      = ["ssh-bastion"]
    match_destination_address = ["any"]
    match_application         = [junos_application.ssh.name]
  }
}

resource "junos_security_policy" "res_to_all" {
  for_each = toset(["dmz", "services"])

  from_zone = junos_security_zone.zone["residential"].name
  to_zone   = each.key

  policy {
    name                      = "res-to-${each.key}"
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

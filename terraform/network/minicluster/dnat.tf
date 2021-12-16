resource "junos_security_nat_destination_pool" "bootmaster" {
  name    = "bootmaster"
  address = "192.168.32.4/32"
}

resource "junos_security_nat_destination" "bootmaster_ssh" {
  name = "bootmaster-ssh"
  from {
    type  = "zone"
    value = ["upstream"]
  }
  rule {
    name                = "bootmaster-ssh"
    destination_address = "0.0.0.0/0"
    destination_port    = ["22"]
    then {
      type = "pool"
      pool = junos_security_nat_destination_pool.bootmaster.name
    }
  }
}

resource "junos_security_policy" "inbound_ssh" {
  from_zone = "upstream"
  to_zone   = "cluster"

  policy {
    name                      = "bootmaster-ssh"
    match_source_address      = ["any"]
    match_destination_address = ["bootmaster"]
    match_application         = [junos_application.ssh.name]
  }
}

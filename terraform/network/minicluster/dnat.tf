resource "junos_security_nat_destination_pool" "bootmaster" {
  name    = "bootmaster"
  address = "192.168.32.2/32"
}

resource "junos_security_nat_destination_pool" "node1" {
  name    = "node1"
  address = "192.168.32.10/32"
}

resource "junos_security_nat_destination" "inbound_dnat" {
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
  rule {
    name                = "node1-http"
    destination_address = "0.0.0.0/0"
    destination_port    = ["80"]
    then {
      type = "pool"
      pool = junos_security_nat_destination_pool.node1.name
    }
  }
}

resource "junos_security_policy" "inbound_svcs" {
  depends_on = [junos_security_address_book.cluster_addresses]

  from_zone = "upstream"
  to_zone   = "cluster"

  policy {
    name                      = "bootmaster-ssh"
    match_source_address      = ["any"]
    match_destination_address = ["bootmaster"]
    match_application         = [junos_application.ssh.name]
  }

  policy {
    name                      = "node1-http"
    match_source_address      = ["any"]
    match_destination_address = ["node1"]
    match_application         = [junos_application.http.name]
  }
}

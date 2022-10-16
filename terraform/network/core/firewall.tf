resource "junos_security_nat_destination_pool" "dmz_bastion" {
  name    = "dmz-bastion"
  address = "192.168.21.5/32"
}

resource "junos_security_nat_destination_pool" "dmz_minecraft" {
  name    = "dmz-minecraft"
  address = "192.168.21.6/32"
}

resource "junos_security_nat_destination_pool" "peer_bgp" {
  name    = "wireguard-bgp"
  address = "169.254.255.3/32"
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

  rule {
    name                = "minecraft"
    destination_address = "0.0.0.0/0"
    destination_port    = ["25565"]
    then {
      type = "pool"
      pool = junos_security_nat_destination_pool.dmz_minecraft.name
    }
  }

  rule {
    name                = "wireguard_bgp"
    destination_address = "0.0.0.0/0"
    destination_port    = ["51821", "51822", "51823", "52820"]
    then {
      type = "pool"
      pool = junos_security_nat_destination_pool.peer_bgp.name
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

  policy {
    name                      = "minecraft"
    match_source_address      = ["any"]
    match_destination_address = ["minecraft"]
    match_application         = [junos_application.minecraft.name]
  }
}

resource "junos_security_policy" "inbound_peers" {
  depends_on = [junos_security_address_book.peer_addresses]

  from_zone = "upstream"
  to_zone   = junos_security_zone.zone["peer_internal"].name

  dynamic "policy" {
    for_each = toset(["51821", "51822", "51823", "52820"])
    content {
      name                      = "wg-bgp-${policy.value}"
      match_source_address      = ["any"]
      match_destination_address = ["mesh1edge1"]
      match_application         = [junos_application.wg_peers[policy.value].name]
    }
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

resource "junos_security_policy" "dmz_to_res" {
  depends_on = [junos_security_address_book.dmz_addresses]

  from_zone = junos_security_zone.zone["dmz"].name
  to_zone   = junos_security_zone.zone["residential"].name

  policy {
    name                      = "bastion-to-res"
    match_source_address      = ["ssh-bastion"]
    match_destination_address = ["any"]
    match_application         = [junos_application.ssh.name]
  }
}

resource "junos_security_policy" "res_to_all" {
  for_each = toset(["dmz", "services", "iot", "telephony"])

  from_zone = junos_security_zone.zone["residential"].name
  to_zone   = each.key

  policy {
    name                      = "res-to-${each.key}"
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

resource "junos_security_policy" "svcs_http" {
  for_each = toset(["mgmt"])

  from_zone = junos_security_zone.zone[each.value].name
  to_zone   = junos_security_zone.zone["services"].name

  policy {
    name                      = "${each.value}-to-services"
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = [junos_application.http.name]
  }
}

resource "junos_security_policy" "res_to_peers" {
  depends_on = [junos_security_address_book.peer_addresses]

  from_zone = junos_security_zone.zone["residential"].name
  to_zone   = junos_security_zone.zone["peer_internal"].name

  policy {
    name                      = "res-to-cluster"
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

resource "junos_security_policy" "peers_to_internal" {
  depends_on = [junos_security_address_book.peer_addresses]

  from_zone = junos_security_zone.zone["peer_internal"].name
  to_zone   = junos_security_zone.zone["dmz"].name

  policy {
    name                      = "peer-to-dmz"
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = [junos_application.http.name]
  }
}

resource "junos_security_policy" "peers_to_telephony" {
  depends_on = [junos_security_address_book.telephony_addresses]

  from_zone = junos_security_zone.zone["peer_internal"].name
  to_zone   = junos_security_zone.zone["telephony"].name

  policy {
    name                      = "peer-to-telephony"
    match_source_address      = ["any"]
    match_destination_address = ["DLLSTXPO01DS0"]
    match_application         = ["any"]
  }
}

resource "junos_security_policy" "svcs_to_iot" {
  from_zone = junos_security_zone.zone["services"].name
  to_zone   = junos_security_zone.zone["iot"].name

  policy {
    name                      = "services-to-iot"
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

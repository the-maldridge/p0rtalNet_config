resource "junos_vlan" "vlans" {
  for_each = var.networks

  name        = format("vlan-%s", each.key)
  description = each.value.description
  vlan_id     = each.value.vlan_id

  l3_interface = format("irb.%d", each.value.vlan_id)
}

resource "junos_interface_logical" "irb" {
  depends_on = [junos_security_zone.zone]
  for_each   = var.networks

  name          = format("irb.%d", each.value.vlan_id)
  description   = each.value.description
  security_zone = junos_security_zone.zone[each.key].name

  family_inet {
    address {
      cidr_ip = format("%s/%s", cidrhost(each.value.cidr, 1), split("/", each.value.cidr)[1])
    }
  }
}

resource "junos_security_zone" "zone" {
  for_each = var.networks

  name = each.key

  inbound_protocols = ["all"]
  inbound_services  = ["all"]

  address_book_configure_singly = true
}

resource "junos_security_nat_source" "nat_to_upstream" {
  depends_on = [junos_security_zone.upstream]

  for_each = { for network, cfg in var.networks : network => cfg if lookup(cfg, "enable_upstream_nat", false) }

  name = format("%s-to-upstream", each.key)

  from {
    type  = "zone"
    value = [each.key]
  }
  to {
    type  = "zone"
    value = [junos_security_zone.upstream.name]
  }

  rule {
    name = format("%s-nat-to-upstream", each.key)
    match {
      source_address = flatten([[each.value.cidr], lookup(each.value, "additional_nat_source", [])])
    }
    then {
      type = "interface"
    }
  }
}

resource "junos_security_policy" "nat_to_upstream" {
  depends_on = [junos_security_zone.upstream]

  for_each = { for network, cfg in var.networks : network => cfg if lookup(cfg, "enable_upstream_nat", false) }

  from_zone = each.key
  to_zone   = "upstream"

  policy {
    name                      = format("%s-to-upstream", each.key)
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

resource "junos_security_policy" "zone_to_self" {
  for_each = var.networks

  from_zone = each.key
  to_zone   = each.key

  policy {
    name                      = format("%s-to-%s", each.key, each.key)
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

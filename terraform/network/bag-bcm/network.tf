resource "junos_interface_physical" "local_port" {
  for_each = toset(["2", "3", "4", "5", "6", "7"])

  name         = format("ge-0/0/%d", each.key)
  vlan_members = [junos_vlan.local.name]
}

resource "junos_vlan" "local" {
  name        = "vlan-local"
  description = "Local Network"
  vlan_id     = 10

  l3_interface = junos_interface_logical.local_vlan.name
}

resource "junos_interface_logical" "local_vlan" {
  depends_on = [junos_security_zone.local]

  name          = "vlan.10"
  description   = "Local Network IRB"
  security_zone = junos_security_zone.local.name

  family_inet {
    address {
      cidr_ip = "172.16.30.1/24"
    }
  }
}

resource "junos_security_zone" "local" {
  name = "local"

  inbound_protocols = ["all"]
  inbound_services  = ["all"]
}

resource "junos_security_nat_source" "nat_to_upstream" {
  depends_on = [junos_security_zone.upstream]

  name = "local-to-upstream"

  from {
    type  = "zone"
    value = ["local"]
  }
  to {
    type  = "zone"
    value = [junos_security_zone.upstream.name]
  }

  rule {
    name = "local-nat-to-upstream"
    match {
      source_address = ["172.16.30.0/24"]
    }
    then {
      type = "interface"
    }
  }
}

resource "junos_security_policy" "nat_to_upstream" {
  from_zone = junos_security_zone.local.name
  to_zone   = junos_security_zone.upstream.name

  policy {
    name                      = "local-to-upstream"
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

resource "junos_security_policy" "zone_to_self" {
  from_zone = junos_security_zone.local.name
  to_zone   = junos_security_zone.local.name

  policy {
    name                      = "local-to-local"
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

resource "junos_access_address_assignment_pool" "local_dhcp_pool" {
  name = "local_dhcp_pool"
  family {
    type    = "inet"
    network = "172.16.30.0/24"

    inet_range {
      name = "default"
      low  = "172.16.30.2"
      high = "172.16.30.127"
    }

    dhcp_attributes {
      maximum_lease_time = 300
      t1_percentage = 50
      t2_percentage = 85
      router = ["172.16.30.1"]
    }

    host {
      name = "bcm"
      hardware_address = "00:1b:25:31:0a:a9"
      ip_address = "172.16.30.5"
    }
  }
}

resource "junos_system_services_dhcp_localserver_group" "local_dhcp_group" {
  name = "local_dhcp_group"
  interface {
    name = junos_interface_logical.local_vlan.name
  }
}

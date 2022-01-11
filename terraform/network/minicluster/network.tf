resource "junos_interface_logical" "cluster_port" {
  for_each = toset(["1", "2", "3", "4", "5", "6"])

  name        = format("ge-0/0/%d.0", each.key)
  description = "Cluster network port"

  security_zone = junos_security_zone.cluster.name
}

resource "junos_interface_physical" "cluster_port" {
  for_each = toset(["1", "2", "3", "4", "5", "6"])

  name         = format("ge-0/0/%d", each.key)
  vlan_members = [junos_vlan.cluster.name]
}

resource "junos_vlan" "cluster" {
  name        = "vlan-cluster"
  description = "Cluster Network"
  vlan_id     = 10

  l3_interface = junos_interface_logical.cluster_vlan.name
}

resource "junos_interface_logical" "cluster_vlan" {
  depends_on = [junos_security_zone.cluster]

  name          = "vlan.10"
  description   = "Cluster Network IRB"
  security_zone = junos_security_zone.cluster.name

  family_inet {
    address {
      cidr_ip = "192.168.32.1/24"
    }
  }
}

resource "junos_security_zone" "cluster" {
  name = "cluster"

  inbound_protocols = ["all"]
  inbound_services  = ["all"]
}

resource "junos_security_nat_source" "nat_to_upstream" {
  depends_on = [junos_security_zone.upstream]

  name = "cluster-to-upstream"

  from {
    type  = "zone"
    value = ["cluster"]
  }
  to {
    type  = "zone"
    value = [junos_security_zone.upstream.name]
  }

  rule {
    name = "cluster-nat-to-upstream"
    match {
      source_address = ["192.168.32.0/24"]
    }
    then {
      type = "interface"
    }
  }
}

resource "junos_security_policy" "nat_to_upstream" {
  from_zone = junos_security_zone.cluster.name
  to_zone   = junos_security_zone.upstream.name

  policy {
    name                      = "cluster-to-upstream"
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

resource "junos_security_policy" "zone_to_self" {
  from_zone = junos_security_zone.cluster.name
  to_zone   = junos_security_zone.cluster.name

  policy {
    name                      = "cluster-to-cluster"
    match_source_address      = ["any"]
    match_destination_address = ["any"]
    match_application         = ["any"]
  }
}

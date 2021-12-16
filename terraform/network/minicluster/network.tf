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

resource "junos_access_address_assignment_pool" "pool" {
  name = "cluster-dhcp"

  family {
    type    = "inet"
    network = "192.168.32.0/24"

    inet_range {
      name = "primary"
      low  = "192.168.32.2"
      high = "192.168.32.64"
    }

    dhcp_attributes {
      router      = ["192.168.32.1"]
      name_server = ["192.168.32.4"]
      domain_name = "lan"

      maximum_lease_time = 600
    }

    host {
      name             = "bootmaster"
      hardware_address = "f4:4d:30:6f:70:c9"
      ip_address       = "192.168.32.4"
    }

    host {
      name             = "node1"
      hardware_address = "00:23:24:5b:85:92"
      ip_address       = "192.168.32.10"
    }

    host {
      name             = "node2"
      hardware_address = "00:23:24:6c:68:5c"
      ip_address       = "192.168.32.11"
    }

    host {
      name             = "node3"
      hardware_address = "00:23:24:79:02:cb"
      ip_address       = "192.168.32.12"
    }

    host {
      name             = "node4"
      hardware_address = "00:23:24:64:1d:59"
      ip_address       = "192.168.32.13"
    }

    host {
      name             = "node5"
      hardware_address = "d8:cb:8a:20:92:e6"
      ip_address       = "192.168.32.14"
    }

    host {
      name             = "node6"
      hardware_address = "00:23:24:78:24:39"
      ip_address       = "192.168.32.15"
    }

    host {
      name             = "node7"
      hardware_address = "00:23:24:76:8b:ed"
      ip_address       = "192.168.32.16"
    }

    host {
      name             = "node8"
      hardware_address = "00:23:24:76:c6:a3"
      ip_address       = "192.168.32.17"
    }

    host {
      name             = "node9"
      hardware_address = "00:23:24:79:02:fa"
      ip_address       = "192.168.32.18"
    }

    host {
      name             = "node10"
      hardware_address = "00:23:24:69:df:c4"
      ip_address       = "192.168.32.19"
    }
  }
}

resource "junos_system_services_dhcp_localserver_group" "local_dhcp" {
  name = "local-dhcp"

  interface {
    name = junos_interface_logical.cluster_vlan.name
  }
}

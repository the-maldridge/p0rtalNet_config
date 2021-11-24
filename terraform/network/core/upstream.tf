resource "junos_security_zone" "upstream" {
  depends_on = [junos_security_screen.upstream]

  name   = "upstream"
  screen = junos_security_screen.upstream.name

  inbound_services = ["dhcp", "tftp"]
}

resource "junos_interface_logical" "upstream" {
  name        = "ge-0/0/0.0"
  description = "Upstream Copper Handoff"

  security_zone = junos_security_zone.upstream.name
  family_inet {
    dhcp {
      srx_old_option_name = true
      vendor_id = "juniper-srx300"
      update_server = true
    }
  }
}

resource "junos_security_screen" "upstream" {
  name = "upstream-screen"

  icmp {
    ping_death = true
  }
  ip {
    source_route_option = true
    tear_drop           = true
  }
  tcp {
    land = true
    syn_flood {
      alarm_threshold       = 1024
      attack_threshold      = 1024
      source_threshold      = 1024
      destination_threshold = 2048
      timeout               = 20
    }
  }
}

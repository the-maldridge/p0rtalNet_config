resource "junos_routing_options" "default" {
  autonomous_system {
    number = 64579
  }
  router_id = "169.254.255.4"
}

resource "junos_policyoptions_policy_statement" "send_direct" {
  name = "send-direct"

  term {
    name = "t1"
    from {
      protocol = ["direct"]
    }
    then {
      action = "accept"
    }
  }

  term {
    name = "t2"
    from {
      protocol = ["access-internal"]
    }
    then {
      action   = "accept"
      next_hop = "self"
    }
  }
}

resource "junos_bgp_group" "internal" {
  name             = "internal-peers"
  type             = "internal"
  routing_instance = "default"
  local_address    = "169.254.255.4"

  export = [junos_policyoptions_policy_statement.send_direct.name]
}

resource "junos_bgp_neighbor" "p0rtalNet_core" {
  ip               = "169.254.255.1"
  routing_instance = "default"
  group            = junos_bgp_group.internal.name
  local_address    = "169.254.255.4"
}

resource "junos_bgp_neighbor" "bag_net" {
  ip               = "169.254.255.5"
  routing_instance = "default"
  group            = junos_bgp_group.internal.name
  local_address    = "169.254.255.4"
}

resource "junos_bgp_neighbor" "sneakynet_rack" {
  ip               = "169.254.255.6"
  routing_instance = "default"
  group            = junos_bgp_group.internal.name
  local_address    = "169.254.255.4"
}

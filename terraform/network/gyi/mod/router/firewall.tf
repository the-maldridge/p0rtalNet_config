resource "routeros_ip_firewall_filter" "accept_established" {
  chain            = "input"
  action           = "accept"
  connection_state = "established,related,untracked"
  comment          = "accept-established"
  place_before     = routeros_ip_firewall_filter.default_drop.id
}

resource "routeros_ip_firewall_filter" "no_invalid" {
  chain            = "input"
  action           = "drop"
  connection_state = "invalid"
  comment          = "drop-invalid"
  place_before     = routeros_ip_firewall_filter.default_drop.id
}

resource "routeros_ip_firewall_filter" "accept_icmp" {
  chain        = "input"
  action       = "accept"
  protocol     = "icmp"
  comment      = "accept-icmp"
  place_before = routeros_ip_firewall_filter.default_drop.id
}

resource "routeros_ip_firewall_filter" "accept_inbound" {
  chain            = "input"
  action           = "accept"
  comment          = "accept-inbound"
  src_address_list = "accept-remote"
  dst_address_type = "local"
  in_interface     = routeros_interface_wireguard.peer.name
  place_before     = routeros_ip_firewall_filter.default_drop.id
}

resource "routeros_ip_firewall_filter" "accept_local" {
  chain            = "input"
  action           = "accept"
  comment          = "accept-local"
  src_address_type = "local"
  dst_address_type = "local"
  place_before     = routeros_ip_firewall_filter.default_drop.id
}

resource "routeros_ip_firewall_filter" "default_drop" {
  chain        = "input"
  action       = "drop"
  comment      = "default-deny"
  in_interface = "!${routeros_interface_vlan.lan.name}"

  disabled = var.bootstrap
}

# Forward Section.  Traffic routed locally.

resource "routeros_ip_firewall_filter" "fasttrack_forward" {
  chain            = "forward"
  action           = "fasttrack-connection"
  connection_state = "established,related"
  comment          = "forward-fasttracked"
  hw_offload       = true
  place_before     = routeros_ip_firewall_filter.drop_forward_default.id
}

resource "routeros_ip_firewall_filter" "accept_forward_icmp" {
  chain        = "forward"
  action       = "accept"
  protocol     = "icmp"
  comment      = "accept-icmp"
  place_before = routeros_ip_firewall_filter.default_drop.id
}

resource "routeros_ip_firewall_filter" "accept_forward" {
  chain            = "forward"
  action           = "accept"
  connection_state = "established,related,untracked"
  comment          = "accept-established"
  place_before     = routeros_ip_firewall_filter.drop_forward_default.id
}

resource "routeros_ip_firewall_filter" "drop_forward_invalid" {
  chain            = "forward"
  action           = "drop"
  connection_state = "invalid"
  comment          = "drop-invalid"
  place_before     = routeros_ip_firewall_filter.drop_forward_default.id
}

resource "routeros_ip_firewall_filter" "accept_forward_inbound" {
  chain            = "forward"
  action           = "accept"
  comment          = "accept-inbound-forward"
  in_interface     = routeros_interface_wireguard.peer.name
  out_interface    = routeros_interface_vlan.lan.name
  src_address_list = "accept-remote"
  place_before     = routeros_ip_firewall_filter.drop_forward_default.id
}

resource "routeros_ip_firewall_filter" "accept_forward_outbound" {
  chain         = "forward"
  action        = "accept"
  comment       = "accept-outbound-forward"
  in_interface  = routeros_interface_vlan.lan.name
  out_interface = routeros_interface_wireguard.peer.name
  place_before  = routeros_ip_firewall_filter.drop_forward_default.id
}

resource "routeros_ip_firewall_filter" "drop_forward_default" {
  chain        = "forward"
  action       = "drop"
  comment      = "default-deny"
  in_interface = "!${routeros_interface_vlan.lan.name}"

  disabled = var.bootstrap
}

# srcnat section - Traffic masquerading outbound.

resource "routeros_ip_firewall_nat" "srcnat" {
  chain         = "srcnat"
  action        = "masquerade"
  out_interface = routeros_interface_vlan.wan.name
  src_address   = var.main_subnet
  comment       = "nat-masquerade"
}

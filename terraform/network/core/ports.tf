resource "junos_interface_physical" "core_sw1" {
  name         = "ge-0/0/1"
  trunk        = true
  vlan_members = [for vlan in junos_vlan.vlans : vlan.id]
  vlan_native  = junos_vlan.vlans["mgmt"].vlan_id
}

resource "junos_interface_physical" "nas" {
  name         = "ge-0/0/3"
  vlan_members = [junos_vlan.vlans["residential"].vlan_id]
}

resource "junos_interface_physical" "svcs_host1" {
  name         = "ge-0/0/4"
  trunk        = true
  vlan_members = [for vlan in junos_vlan.vlans : vlan.id]
}

resource "junos_interface_physical" "net_svcs_host" {
  name         = "ge-0/0/5"
  trunk        = true
  vlan_members = [for vlan in junos_vlan.vlans : vlan.id]
}

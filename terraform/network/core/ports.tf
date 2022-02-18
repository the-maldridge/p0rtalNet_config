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

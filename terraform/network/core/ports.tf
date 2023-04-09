resource "junos_interface_physical" "core_sw1" {
  name         = "ge-0/0/1"
  trunk        = true
  vlan_members = [for vlan in junos_vlan.vlans : vlan.id]
  vlan_native  = junos_vlan.vlans["mgmt"].vlan_id
}

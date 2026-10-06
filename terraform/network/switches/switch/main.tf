resource "aoss_hostname" "hostname" {
  hostname = var.hostname
}


data "aoss_interfaces" "interfaces" {}

resource "aoss_interface" "interface" {
  for_each = { for iface, attr in data.aoss_interfaces.interfaces.interfaces :
    attr.number => {
      number   = attr.number
      shutdown = !contains(keys(var.interfaces), tostring(attr.number))
      name     = try(lookup(lookup(var.interfaces, attr.number), "name", ""), "")
    } if attr.type == "physical"
  }

  interface = each.value.number
  name      = each.value.name
  shutdown  = each.value.shutdown
}

resource "aoss_vlan" "vlan" {
  for_each = var.vlans

  vlan_id = each.value.id
  name    = each.value.name
  dhcp    = each.value.use_dhcp
  tagged = flatten([
    each.value.tagged,
    [for t in keys(var.trunks) : title(t)],
    [for iface, attrs in var.interfaces : iface if contains(lookup(attrs, "tagged", []), each.key)]
  ])
  untagged = flatten([
    each.value.untagged,
    [for iface, attrs in var.interfaces : iface if contains(lookup(attrs, "untagged", []), each.key)]
  ])
}

resource "aoss_management_vlan" "mgmt" {
  vlan_id = one([for vlan in var.vlans : vlan.id if vlan.is_mgmt])
}

resource "aoss_primary_vlan" "primary" {
  vlan_id = one([for vlan in var.vlans : vlan.id if vlan.is_primary])
}

resource "aoss_trunk" "trunk" {
  for_each = var.trunks

  name  = each.key
  ports = each.value.members
}

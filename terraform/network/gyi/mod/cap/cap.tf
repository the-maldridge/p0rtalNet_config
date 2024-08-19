resource "routeros_interface_wireless_cap" "settings" {
  caps_man_addresses = [var.capsman_address]
  bridge             = routeros_interface_bridge.br0.name
  enabled            = true
  interfaces         = ["wlan1", "wlan2"]
}

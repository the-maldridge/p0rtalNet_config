resource "routeros_wifi_cap" "settings" {
  caps_man_addresses = ["192.168.31.1"]
  enabled = true
  slaves_datapath = routeros_wifi_datapath.datapath.name
}

resource "routeros_wifi_datapath" "datapath" {
  name = "capdp"
  bridge = routeros_interface_bridge.br0.name
}

resource "routeros_wifi" "wifi1" {
  configuration = {
    manager = "capsman-or-local"
    country = "United States"
  }
  name = "wifi1"
  datapath = {
    config = routeros_wifi_datapath.datapath.name
  }
  disabled = false
}

resource "routeros_wifi" "wifi2" {
  configuration = {
    manager = "capsman-or-local"
    country = "United States"
  }
  name = "wifi2"
  datapath = {
    config = routeros_wifi_datapath.datapath.name
  }
  disabled = false
}

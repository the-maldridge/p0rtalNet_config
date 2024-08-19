resource "routeros_capsman_manager" "mgr" {
  enabled        = true
  upgrade_policy = "require-same-version"
  certificate    = "auto"
  ca_certificate = "auto"
}

resource "routeros_capsman_channel" "channel" {
  for_each = {
    wifi-2ghz = { band = "2ghz-g/n" }
    wifi-5ghz = { band = "5ghz-n/ac" }
  }
  name = each.key
  band = each.value.band
}

resource "routeros_interface_wireless_cap" "settings" {
  caps_man_addresses = [cidrhost(var.main_subnet, 1)]
  bridge             = routeros_interface_bridge.br0.name
  enabled            = true
  interfaces         = ["wlan1", "wlan2"]
  certificate        = routeros_capsman_manager.mgr.generated_certificate
}

resource "routeros_capsman_datapath" "lan" {
  name    = "lan"
  vlan_id = routeros_interface_vlan.lan.vlan_id
  bridge  = routeros_interface_bridge.br0.name

  local_forwarding = true
  vlan_mode        = "use-tag"
}

resource "routeros_capsman_security" "lan" {
  name                 = "lan"
  authentication_types = ["wpa2-psk"]
  passphrase           = var.wifi.psk
  encryption           = ["tkip", "aes-ccm"]
}

resource "routeros_capsman_configuration" "lan" {
  for_each = routeros_capsman_channel.channel

  name    = each.key
  ssid    = var.wifi.ssid
  mode    = "ap"
  country = "united states3"

  channel = {
    config = routeros_capsman_channel.channel[each.key].name
  }

  security = {
    config = routeros_capsman_security.lan.name
  }

  datapath = {
    config = routeros_capsman_datapath.lan.name
  }
}

resource "routeros_capsman_provisioning" "provisioning_5ghz" {
  master_configuration = routeros_capsman_configuration.lan["wifi-5ghz"].name
  action               = "create-dynamic-enabled"
  hw_supported_modes   = "ac"
}

resource "routeros_capsman_provisioning" "provisioning_2ghz" {
  master_configuration = routeros_capsman_configuration.lan["wifi-2ghz"].name
  action               = "create-dynamic-enabled"
  hw_supported_modes   = "gn"
}

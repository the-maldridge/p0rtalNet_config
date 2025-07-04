resource "routeros_system_identity" "identity" {
  name = "core0"
}

resource "routeros_ip_dns" "dns" {
  allow_remote_requests = true
  servers               = ["8.8.8.8", "8.8.4.4"]

  mdns_repeat_ifaces = [for iface, net in var.networks : iface if net.bridge_mdns]
}

resource "routeros_ip_service" "disabled" {
  for_each = {
    api-ssl = 8729
    api     = 8278
    ftp     = 21
    telnet  = 21
    winbox  = 8291
    www     = 80
  }

  numbers  = each.key
  port     = each.value
  disabled = true
}

resource "routeros_ip_service" "enabled" {
  for_each = {
    ssh = 22
  }

  numbers = each.key
  port    = each.value
  address = var.networks["mgmt"].cidr
}

resource "routeros_ip_service" "www_ssl" {
  numbers     = "www-ssl"
  port        = 443
  address     = var.networks["mgmt"].cidr
  certificate = "self"
}

resource "routeros_ip_cloud" "ddns" {
  ddns_enabled = "yes"
}

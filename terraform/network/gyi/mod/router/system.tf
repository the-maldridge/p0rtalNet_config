resource "routeros_system_identity" "identity" {
  name = "gyi0"
}

resource "routeros_ip_dns" "dns" {
  allow_remote_requests = true
  servers               = ["8.8.8.8", "8.8.4.4"]
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
  address = join(",", flatten([var.main_subnet, var.inbound_subnets]))
}

resource "routeros_ip_service" "www_ssl" {
  count       = var.bootstrap ? 0 : 1
  numbers     = "www-ssl"
  port        = 443
  address     = join(",", flatten([var.main_subnet, var.inbound_subnets]))
  certificate = "self"
}

resource "routeros_ip_cloud" "ddns" {
  ddns_enabled = true
}

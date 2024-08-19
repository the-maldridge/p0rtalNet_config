module "router" {
  source = "./mod/router"

  bootstrap       = false
  domain          = "gyi.michaelwashere.net"
  peer_config     = var.peer_config
  inbound_subnets = ["192.168.16.0/20"]

  wifi = {
    ssid = var.wifi.ssid
    psk  = var.wifi.psk
  }

  reserved_addresses = {
    cap1 = {
      mac  = "78:9A:18:78:A6:21"
      addr = "192.168.64.2"
    }
  }
}

module "cap1" {
  source = "./mod/cap"
  providers = {
    routeros = routeros.cap1
  }

  bootstrap = false
  hostname  = "cap1"

  service_nets = ["192.168.64.0/24", "192.168.16.0/20"]

  capsman_address = "192.168.64.1"
}

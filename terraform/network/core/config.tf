module "edge01" {
  source = "./mod/router"

  networks           = var.networks
  reserved_addresses = var.reserved_addresses
  bgp_peers          = var.bgp_peers
  wifi               = var.wifi
}

module "cap1" {
  source = "./mod/wap"
  providers = {
    routeros = routeros.cap1
  }

  bootstrap = false

  networks            = var.networks
  hostname            = "cap1"
  capsman_certificate = module.edge01.capsman_certificate
}

module "cap2" {
  source = "./mod/wap"
  providers = {
    routeros = routeros.cap2
  }

  bootstrap = false

  networks            = var.networks
  hostname            = "cap2"
  capsman_certificate = module.edge01.capsman_certificate
}

module "edge01" {
  source = "./mod/router"

  networks = var.networks
  reserved_addresses = var.reserved_addresses
  bgp_peers = var.bgp_peers
}

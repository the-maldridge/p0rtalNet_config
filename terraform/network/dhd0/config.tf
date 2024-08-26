module "dhd0" {
  source = "../core/mod/dhd"

  bootstrap   = false
  hostname    = "dhd0"
  domain      = "dhd0.michaelwashere.net"
  peer_config = var.peer_config

  main_subnet     = "192.168.33.0/24"
  inbound_subnets = ["192.168.16.0/20", "172.16.31.0/24"]
}

variable "peer_config" {
  type = map(object({
    privkey    = string
    pubkey     = string
    listen     = number
    local_addr = string
    addr       = string
    endpoint   = optional(string)
    as         = number
  }))
  description = "Configuration for BGP Peers"
}

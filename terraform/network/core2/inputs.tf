variable "networks" {
  type = map(object({
    description           = string
    vlan_id               = number
    cidr                  = string
    enable_upstream_nat   = bool
    enable_mesh_export    = optional(bool, false)
    additional_nat_source = list(string)
  }))
  description = "Input structure containing list of networks to provision"
}

variable "reserved_addresses" {
  type = map(object({
    mac  = string
    addr = string
    net  = string
  }))
  description = "Map of machine to mac and address"
}

variable "bgp_peers" {
  description = "Peer configuration"
  type = map(object({
    privkey    = string
    pubkey     = string
    listen     = number
    local_addr = string
    addr       = string
    endpoint   = optional(string)
    as         = number
    bgp        = optional(bool, true)
  }))
}

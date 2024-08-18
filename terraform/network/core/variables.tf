variable "networks" {
  type = map(object({
    description           = string
    vlan_id               = number
    cidr                  = string
    enable_upstream_nat   = optional(bool, true)
    enable_mesh_export    = optional(bool, false)
    additional_nat_source = optional(list(string), [])
    enable_wifi           = optional(bool, false)
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

variable "wifi" {
  description = "WiFi SSIDs and PSKs"
  type = map(list(object({
    ssid   = string
    band   = optional(list(string), ["5ghz"])
    auth   = optional(list(string), ["wpa2-psk", "wpa3-psk"])
    psk    = string
    hide   = optional(bool, false)
    master = optional(bool, false)
  })))
}

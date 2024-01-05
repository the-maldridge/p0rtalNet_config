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

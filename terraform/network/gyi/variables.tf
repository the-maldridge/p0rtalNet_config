variable "wifi" {
  type = object({
    ssid = string
    psk  = string
  })
  description = "WiFi Parameters"
}

variable "peer_config" {
  type = object({
    privkey    = string
    pubkey     = string
    listen     = number
    local_addr = string
    addr       = string
    endpoint   = optional(string)
    as         = number
  })
  description = "Configuration for BGP Peer"
}

variable "main_subnet" {
  type        = string
  description = "Main address pool for all home things."
  default     = "192.168.64.0/24"
}

variable "inbound_subnets" {
  type        = set(string)
  description = "Addresses that will be accepted from remotes"
  default     = []
}

variable "domain" {
  type        = string
  description = "Domain for the local network"
}

variable "bootstrap" {
  type        = bool
  description = "Enable bootstrap mode"
  default     = false
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

variable "reserved_addresses" {
  type = map(object({
    mac  = string
    addr = string
  }))
  description = "Map of machine to mac and address"
  default     = {}
}

variable "wifi" {
  type = object({
    ssid = string
    psk  = string
  })
  description = "WiFi Parameters"
}

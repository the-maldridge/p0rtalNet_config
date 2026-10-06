variable "hostname" {
  type        = string
  description = "Switch hostname"
}

variable "trunks" {
  type = map(object({
    members = list(number)
  }))
  description = "Map of Trunk interface to Member Interfaces"
}

variable "vlans" {
  type = map(object({
    id         = number
    name       = string
    is_primary = optional(bool, false)
    is_mgmt    = optional(bool, false)
    use_dhcp   = optional(bool, false)
    tagged     = optional(list(string), [])
    untagged   = optional(list(string), [])
  }))
  description = "VLAN configuration for the switch"
}

variable "interfaces" {
  type = map(object({
    name     = string
    tagged   = optional(list(string), [])
    untagged = optional(list(string), [])
  }))
  default     = {}
  description = "Interface Configuration"
}

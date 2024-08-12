variable "bootstrap" {
  type = bool
  default = false
  description = "Changes a number of parameters to avoid locking out the device"
}

variable "hostname" {
  type = string
  description = "Access Point Hostname"
}

variable "capsman_certificate" {
  type = string
  description = "Certificate to bind with capsman"
}

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

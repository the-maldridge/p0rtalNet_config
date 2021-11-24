variable "networks" {
  type = map(object({
    description         = string
    vlan_id             = number
    cidr                = string
    enable_upstream_nat = bool
  }))
  description = "Input structure containing list of networks to provision"
}

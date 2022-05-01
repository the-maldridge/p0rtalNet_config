variable "networks" {
  type = map(object({
    description           = string
    vlan_id               = number
    cidr                  = string
    enable_upstream_nat   = bool
    additional_nat_source = list(string)
  }))
  description = "Input structure containing list of networks to provision"
}

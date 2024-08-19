variable "bootstrap" {
  type        = bool
  default     = false
  description = "Changes a number of parameters to avoid locking out the device"
}

variable "hostname" {
  type        = string
  description = "Access Point Hostname"
}

variable "capsman_address" {
  type        = string
  description = "Address of the CAPsMAN"
}

variable "service_nets" {
  type        = list(string)
  description = "List of CIDRs that should present services"
}

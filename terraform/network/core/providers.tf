terraform {
  required_providers {
    routeros = {
      source = "terraform-routeros/routeros"
    }
  }

  backend "http" {
    address        = "http://terrastate.dal.michaelwashere.net/state/prod/net-core"
    lock_address   = "http://terrastate.dal.michaelwashere.net/state/prod/net-core"
    unlock_address = "http://terrastate.dal.michaelwashere.net/state/prod/net-core"
  }
}

provider "routeros" {
  hosturl = "https://192.168.31.1"
}

provider "routeros" {
  alias   = "cap1"
  hosturl = "https://192.168.31.20"
}

provider "routeros" {
  alias   = "cap2"
  hosturl = "https://192.168.31.21"
}

terraform {
  required_providers {
    routeros = {
      source = "terraform-routeros/routeros"
    }
  }
}

provider "routeros" {
  hosturl = "https://192.168.31.1"
}

provider "routeros" {
  alias = "cap1"
  hosturl = "https://192.168.31.20"
}

terraform {
  required_providers {
    aoss = {
      source = "the-maldridge/aoss"
    }
  }
}

provider "aoss" {
  host = "${terraform.workspace}.dal.michaelwashere.net"
}

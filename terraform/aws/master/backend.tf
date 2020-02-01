terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "p0rtalNet"

    workspaces {
      name = "aws-master"
    }
  }
}

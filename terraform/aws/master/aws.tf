provider "aws" {
  region = "us-west-1"

  assume_role {
    role_arn = "arn:aws:iam::658087274246:role/root"
  }
}

module "setup" {
  source = "../../modules/aws-root-setup"
}

output "root_arn" {
  value = module.setup.root_arn
}

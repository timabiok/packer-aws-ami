#-----------------------------------------------------------------------------
# Create VPC via terraform-aws-vpc module
# Run this when you want to create a new network. For existing IDs use network-existing/.
#-----------------------------------------------------------------------------
module "vpc" {
  source = "git::https://github.com/timabiok/terraform-aws-vpc.git?ref=main"

  region                     = var.region
  env                        = var.env
  app                        = var.app
  owner                      = var.owner
  vpc_cidr                   = var.vpc_cidr
  single_nat_gateway         = var.single_nat_gateway
  allowed_https_cidr_blocks   = var.allowed_https_cidr_blocks
  allowed_ssh_cidr_blocks    = var.allowed_ssh_cidr_blocks
  db_ingress_ports           = var.db_ingress_ports
}

provider "aws" {
  region = var.region
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  my_ip_cidr = "${trimspace(data.http.my_ip.response_body)}/32"

  azs = [
    "${var.region}a",
    "${var.region}b",
    "${var.region}c"
  ]

  private_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 1),
    cidrsubnet(var.vpc_cidr, 8, 2),
    cidrsubnet(var.vpc_cidr, 8, 3),
    cidrsubnet(var.vpc_cidr, 8, 4),
    cidrsubnet(var.vpc_cidr, 8, 5)
  ]

  public_subnet = cidrsubnet(var.vpc_cidr, 8, 10)
}

module "network" {
  source          = "../../modules/network"
  vpc_cidr        = var.vpc_cidr
  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnet   = local.public_subnet
}

module "security" {
  source      = "../../modules/security"
  vpc_id      = module.network.vpc_id
  vpc_cidr    = var.vpc_cidr
  my_ip_cidr  = local.my_ip_cidr
}

module "compute" {
  source              = "../../modules/compute"
  ami                 = var.ami
  instance_type       = var.instance_type
  key_name            = var.key_name
  public_key          = file(var.public_key_path)
  private_subnet_ids  = module.network.private_subnet_ids
  public_subnet_id    = module.network.public_subnet_id
  k0s_sg_id           = module.security.k0s_sg_id
  openvpn_sg_id       = module.security.openvpn_sg_id
}

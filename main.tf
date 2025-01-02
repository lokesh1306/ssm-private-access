locals {
  common_tags = merge(var.additional_tags, {
    Environment = var.env
  })
}

terraform {
  backend "s3" {
    bucket         = "tf-state-lokesh"
    key            = "prod/init/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-state-lokesh"
    profile        = "infra"
  }
}

module "network" {
  source               = "./modules/network"
  common_tags          = local.common_tags
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  azs                  = var.azs
}

module "ssm" {
  source                = "./modules/ssm"
  common_tags           = local.common_tags
  vpc_id                = module.network.vpc_id
  region                = var.region
  private_subnet_ids    = module.network.private_subnet_ids
  bastion_ami_id        = var.bastion_ami_id
  bastion_instance_type = var.bastion_instance_type
  vpc_cidr              = var.vpc_cidr
}

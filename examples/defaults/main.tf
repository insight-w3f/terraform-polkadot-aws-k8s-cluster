variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}

resource "random_pet" "this" {
  length = 2
}

module "network" {
  source       = "github.com/insight-w3f/terraform-polkadot-aws-network.git?ref=master"
  num_azs      = 3
  cluster_name = random_pet.this.id
  k8s_enabled  = true
}

module "eks" {
  source            = "../.."
  cluster_name      = random_pet.this.id
  security_group_id = module.network.k8s_security_group_id
  subnet_ids        = slice(module.network.public_subnets, 0, 3)
  vpc_id            = module.network.vpc_id
}

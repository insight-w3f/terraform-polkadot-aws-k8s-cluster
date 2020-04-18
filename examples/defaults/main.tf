variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "1.10"
}

resource "random_pet" "this" {
  length = 2
}

module "network" {
  source       = "github.com/insight-w3f/terraform-polkadot-aws-network.git?ref=master"
  num_azs      = 3
  cluster_name = random_pet.this.id
  k8s_enabled = true
}

module "eks" {
  source            = "../.."
  cluster_name      = random_pet.this.id
  security_group_id = module.network.k8s_security_group_id
  subnet_ids        = slice(module.network.public_subnets, 0, 3)
  vpc_id            = module.network.vpc_id
}

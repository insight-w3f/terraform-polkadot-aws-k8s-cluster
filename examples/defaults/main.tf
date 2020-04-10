variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.defaults.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.defaults.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

resource "random_pet" "this" {
  length = 2
}

module "network" {
  source       = "github.com/insight-w3f/terraform-polkadot-aws-network.git?ref=master"
  all_enabled  = true
  num_azs      = 3
  cluster_name = random_pet.this.id
}

module "defaults" {
  source            = "../.."
  cluster_name      = random_pet.this.id
  cluster_id        = "testing-${random_pet.this.id}"
  security_group_id = module.network.k8s_security_group_id
  subnet_ids        = slice(module.network.public_subnets, 0, 3)
  vpc_id            = module.network.vpc_id
}

output "k8s_security_group_id" {
  value = module.network.k8s_security_group_id
}

module "label" {
  source = "github.com/robc-io/terraform-null-label.git?ref=0.16.1"
  tags = {
    NetworkName = var.network_name
    Owner       = var.owner
    Terraform   = true
    VpcType     = "main"
  }

  environment = var.environment
  namespace   = var.namespace
  stage       = var.stage
}

module "eks" {
  source     = "github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v13.2.1"
  create_eks = var.create

  cluster_name    = module.label.id
  cluster_version = "1.17"
  enable_irsa     = true

  subnets = var.subnet_ids
  vpc_id  = var.vpc_id

  cluster_security_group_id            = var.security_group_id
  worker_additional_security_group_ids = var.worker_additional_security_group_ids

  worker_groups = local.worker_group

  tags = module.label.tags
}

data "aws_region" "this" {}
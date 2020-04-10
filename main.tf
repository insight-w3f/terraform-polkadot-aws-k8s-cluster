locals {
  prometheus_enabled    = var.all_enabled ? true : var.prometheus_enabled
  consul_enabled        = var.all_enabled ? true : var.consul_enabled
  elasticsearch_enabled = var.all_enabled ? true : var.elasticsearch_enabled
}

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
  source     = "github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v11.0.0"
  create_eks = var.create

  cluster_name = var.cluster_name

  subnets = var.subnet_ids
  vpc_id  = var.vpc_id

  cluster_security_group_id            = var.security_group_id
  worker_additional_security_group_ids = var.worker_additional_security_group_ids

  //  manage_worker_iam_resources = true

  worker_groups = [
    {
      name          = "workers"
      instance_type = var.worker_instance_type
      asg_max_size  = var.num_workers
      //      iam_role_id = aws_iam_role.this.id
      //      iam_instance_profile_name = aws_iam_instance_profile.this.id
      //      tags = concat([{
      //          key = "Name"
      //          value = "${var.cluster_id}-workers-1"
      //          propagate_at_launch = true
      //        }
      //      ], module.label.tags_as_list_of_maps)
    }
  ]

  //  tags = module.label.tags
}
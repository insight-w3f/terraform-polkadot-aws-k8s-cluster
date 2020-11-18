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
  source     = "github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v10.0.0"
  create_eks = var.create

  cluster_name    = module.label.id
  cluster_version = "1.16"

  subnets = var.subnet_ids
  vpc_id  = var.vpc_id

  cluster_security_group_id            = var.security_group_id
  worker_additional_security_group_ids = var.worker_additional_security_group_ids

  worker_groups = [
    {
      name                 = "on-demand-workers-1"
      instance_type        = var.worker_instance_type
      asg_desired_capacity = var.num_workers
      asg_min_size         = var.cluster_autoscale_min_workers
      asg_max_size         = var.cluster_autoscale_max_workers
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=normal"
      suspended_processes  = ["AZRebalance"]
      tags = concat([{
        key                 = "Name"
        value               = "${module.label.id}-on-demand-workers-1"
        propagate_at_launch = true
        }
      ])
      }, var.use_spot_instances ? {
      name                 = "spot-workers-1"
      instance_type        = var.worker_instance_type
      asg_desired_capacity = var.spot_num_workers
      asg_min_size         = var.spot_cluster_min_workers
      asg_max_size         = var.spot_cluster_max_workers
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes  = ["AZRebalance"]
      tags = concat([{
        key                 = "Name"
        value               = "${module.label.id}-spot-workers-1"
        propagate_at_launch = true
        }
      ])
    } : null
  ]

  tags = module.label.tags
}

data "aws_region" "this" {}
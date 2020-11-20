locals {
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler-chart"

  raw_worker_groups = concat([
    var.cluster_autoscale ?
    # ON DEMAND, AUTOSCALE ENABLED
    {
      name                 = "on-demand-workers-1"
      instance_type        = var.worker_instance_type
      asg_desired_capacity = var.cluster_autoscale_min_workers
      asg_min_size         = var.cluster_autoscale_min_workers
      asg_max_size         = var.cluster_autoscale_max_workers
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=normal"
      suspended_processes  = ["AZRebalance"]
      tags = concat([{
        key                 = "Name"
        value               = "${module.label.id}-on-demand-workers-1"
        propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/enabled"
          propagate_at_launch = false
          value               = "true"
        },
        {
          key                 = "k8s.io/cluster-autoscaler/${module.label.id}"
          propagate_at_launch = false
          value               = "true"
        }
      ])
    } : null], [! var.cluster_autoscale ?
    # ON DEMAND, NO AUTOSCALE
    {
      name                 = "on-demand-workers-1"
      instance_type        = var.worker_instance_type
      asg_desired_capacity = var.num_workers
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=normal"
      suspended_processes  = ["AZRebalance"]
      tags = concat([{
        key                 = "Name"
        value               = "${module.label.id}-on-demand-workers-1"
        propagate_at_launch = true
        }
      ])
    } : null],
    [var.use_spot_instances && var.spot_autoscale ? {
      # SPOT, AUTOSCALE ENABLED
      name                 = "spot-workers-1"
      instance_type        = var.worker_instance_type
      asg_desired_capacity = var.spot_cluster_min_workers
      asg_min_size         = var.spot_cluster_min_workers
      asg_max_size         = var.spot_cluster_max_workers
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes  = ["AZRebalance"]
      tags = concat([{
        key                 = "Name"
        value               = "${module.label.id}-spot-workers-1"
        propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/enabled"
          propagate_at_launch = false
          value               = "true"
        },
        {
          key                 = "k8s.io/cluster-autoscaler/${module.label.id}"
          propagate_at_launch = false
          value               = "true"
        }
      ])
    } : null],
    [! var.use_spot_instances && ! var.spot_autoscale ? {
      # SPOT, NO AUTOSCALE
      name                 = "spot-workers-1"
      instance_type        = var.worker_instance_type
      asg_desired_capacity = var.spot_num_workers
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes  = ["AZRebalance"]
      tags = concat([{
        key                 = "Name"
        value               = "${module.label.id}-spot-workers-1"
        propagate_at_launch = true
        }
      ])
    } : null]
  )

  worker_group = [for item in local.raw_worker_groups : item if item != null]
}
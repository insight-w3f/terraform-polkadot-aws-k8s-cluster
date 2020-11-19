data "template_file" "autoscaler-values" {
  template = yamlencode(yamldecode(file("${path.module}/autoscale-chart-values-template.yaml")))
  vars = {
    region                    = data.aws_region.this.id
    k8s_service_account_name  = local.k8s_service_account_name
    irsa_assumable_role_admin = module.iam_assumable_role_admin.this_iam_role_arn
    cluster_name              = module.eks.cluster_id
  }
}

resource "helm_release" "autoscaler" {
  count      = var.spot_autoscale || var.cluster_autoscale ? 1 : 0
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler-chart"
  name       = "aws-autoscaler"
  namespace  = local.k8s_service_account_namespace
  values     = [data.template_file.autoscaler-values.rendered]
}
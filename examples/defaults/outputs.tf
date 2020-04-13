
data "aws_caller_identity" "this" {}

output "caller_identity" {
  value = data.aws_caller_identity.this.id
}

output "k8s_security_group_id" {
  value = module.network.k8s_security_group_id
}

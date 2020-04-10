
data "aws_caller_identity" "this" {}

output "caller_identity" {
  value = data.aws_caller_identity.this.id
}
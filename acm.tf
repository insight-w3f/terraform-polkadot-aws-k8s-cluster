//variable "root_domain_name" {}


module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  create_certificate = var.root_domain_name == "" ? false : true

  domain_name = var.root_domain_name
  zone_id     = join("", data.aws_route53_zone.this.*.id)

  subject_alternative_names = [
    "*.${var.root_domain_name}",
  ]

  tags = module.label.tags
}

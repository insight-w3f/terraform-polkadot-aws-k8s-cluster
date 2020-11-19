# terraform-polkadot-aws-k8s-cluster

[![open-issues](https://img.shields.io/github/issues-raw/insight-w3f/terraform-polkadot-aws-k8s-cluster?style=for-the-badge)](https://github.com/insight-w3f/terraform-polkadot-aws-k8s-cluster/issues)
[![open-pr](https://img.shields.io/github/issues-pr-raw/insight-w3f/terraform-polkadot-aws-k8s-cluster?style=for-the-badge)](https://github.com/insight-w3f/terraform-polkadot-aws-k8s-cluster/pulls)

## Features

This module sets up an EKS cluster on AWS.  It wraps the official (terraform-aws-eks)[https://github.com/terraform-aws-modules/terraform-aws-eks] 
module with sane defaults for it's application. 

## Terraform Versions

For Terraform v0.12.0+

## Usage

```hcl-terraform
module "network" {
  source       = "github.com/insight-w3f/terraform-polkadot-aws-network.git?ref=master"
  all_enabled  = true
  num_azs      = 3
  cluster_name = random_pet.this.id
}

module "eks" {
  source            = "../.."
  cluster_name      = random_pet.this.id
  security_group_id = module.network.k8s_security_group_id
  subnet_ids        = slice(module.network.public_subnets, 0, 3)
  vpc_id            = module.network.vpc_id
}
```
## Examples

- [defaults](https://github.com/insight-w3f/terraform-polkadot-aws-k8s-cluster/tree/master/examples/defaults)

## Known  Issues
No issue is creating limit on this module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_autoscale | Do you want the cluster's worker pool to autoscale? | `bool` | `false` | no |
| cluster\_autoscale\_max\_workers | Maximum number of workers in worker pool | `number` | `1` | no |
| cluster\_autoscale\_min\_workers | Minimum number of workers in worker pool | `number` | `1` | no |
| create | Bool for creation | `bool` | `true` | no |
| environment | The environment | `string` | `"test"` | no |
| namespace | The namespace to deploy into | `string` | `"polkadot"` | no |
| network\_name | The network name, ie kusama / mainnet | `string` | `"kusama"` | no |
| num\_workers | Number of workers for worker pool | `number` | `1` | no |
| owner | Owner of the infrastructure | `string` | `"insight"` | no |
| security\_group\_id | security group id for workers | `string` | n/a | yes |
| spot\_autoscale | Bool to enable the use of autoscaler in spot pool | `bool` | `false` | no |
| spot\_cluster\_max\_workers | Maximum number of workers in SPOT pool | `number` | `10` | no |
| spot\_cluster\_min\_workers | Minimum number of workers in SPOT pool | `number` | `0` | no |
| spot\_num\_workers | Number of workers in SPOT pool when autoscaling disabled | `number` | `1` | no |
| stage | The stage of the deployment | `string` | `"test"` | no |
| subnet\_ids | The id of the subnet. | `list(string)` | n/a | yes |
| use\_spot\_instances | Bool to enable use of spot instances as well as on-demand | `bool` | `false` | no |
| vpc\_id | The vpc id | `string` | n/a | yes |
| worker\_additional\_security\_group\_ids | List of security group ids for workers | `list(string)` | `[]` | no |
| worker\_instance\_type | The instance class for workers | `string` | `"r5.large"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudwatch\_log\_group\_name | Name of cloudwatch log group created |
| cluster\_arn | The Amazon Resource Name (ARN) of the cluster. |
| cluster\_certificate\_authority\_data | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| cluster\_endpoint | The endpoint for your EKS Kubernetes API. |
| cluster\_iam\_role\_arn | IAM role ARN of the EKS cluster. |
| cluster\_iam\_role\_name | IAM role name of the EKS cluster. |
| cluster\_id | The name/id of the EKS cluster. |
| cluster\_oidc\_issuer\_url | The URL on the EKS cluster OIDC Issuer |
| cluster\_security\_group\_id | Security group ID attached to the EKS cluster. |
| cluster\_version | The Kubernetes server version for the EKS cluster. |
| config\_map\_aws\_auth | A kubernetes configuration to authenticate to this EKS cluster. |
| kubeconfig | kubectl config file contents for this EKS cluster. |
| kubeconfig\_filename | The filename of the generated kubectl config. |
| node\_groups | Outputs from EKS node groups. Map of maps, keyed by var.node\_groups keys |
| oidc\_provider\_arn | The ARN of the OIDC Provider if `enable_irsa = true`. |
| worker\_iam\_instance\_profile\_arns | default IAM instance profile ARN for EKS worker groups |
| worker\_iam\_instance\_profile\_names | default IAM instance profile name for EKS worker groups |
| worker\_iam\_role\_arn | default IAM role ARN for EKS worker groups |
| worker\_iam\_role\_name | default IAM role name for EKS worker groups |
| worker\_security\_group\_id | Security group ID attached to the EKS workers. |
| workers\_asg\_arns | IDs of the autoscaling groups containing workers. |
| workers\_asg\_names | Names of the autoscaling groups containing workers. |
| workers\_default\_ami\_id | ID of the default worker group AMI |
| workers\_launch\_template\_arns | ARNs of the worker launch templates. |
| workers\_launch\_template\_ids | IDs of the worker launch templates. |
| workers\_launch\_template\_latest\_versions | Latest versions of the worker launch templates. |
| workers\_user\_data | User data of worker groups |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing
This module has been packaged with terratest tests

To run them:

1. Install Go
2. Run `make test-init` from the root of this repo
3. Run `make test` again from root

## Authors

Module managed by [insight-w3f](https://github.com/insight-w3f)

## Credits

- [Anton Babenko](https://github.com/antonbabenko)

## License

Apache 2 Licensed. See LICENSE for full details.
variable "create" {
  description = "Bool for creation"
  type        = bool
  default     = true
}

########
# Label
########
variable "environment" {
  description = "The environment"
  type        = string
  default     = "test"
}

variable "namespace" {
  description = "The namespace to deploy into"
  type        = string
  default     = "polkadot"
}

variable "stage" {
  description = "The stage of the deployment"
  type        = string
  default     = "test"
}

variable "network_name" {
  description = "The network name, ie kusama / mainnet"
  type        = string
  default     = "kusama"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "insight"
}


#########
# Network
#########
variable "vpc_id" {
  description = "The vpc id"
  type        = string
}

variable "subnet_ids" {
  description = "The id of the subnet."
  type        = list(string)
}

variable "security_group_id" {
  description = "security group id for workers"
  type        = string
}

variable "worker_additional_security_group_ids" {
  description = "List of security group ids for workers"
  type        = list(string)
  default     = []
}

#####
# K8S
#####
variable "worker_instance_type" {
  description = "The instance class for workers"
  type        = string
  default     = "r5.large"
}

//variable "cluster_name" {
//  description = "Name of the k8s cluster"
//  type        = string
//}

//variable "k8s_version" {
//  description = "Version of k8s to use - override to use a version other than `latest`"
//  type        = string
//  default     = null
//}

variable "num_workers" {
  description = "Number of workers for worker pool"
  type        = number
  default     = 1
}

variable "cluster_autoscale" {
  description = "Do you want the cluster's worker pool to autoscale?"
  type        = bool
  default     = false
}

variable "cluster_autoscale_min_workers" {
  description = "Minimum number of workers in worker pool"
  type        = number
  default     = 1
}

variable "cluster_autoscale_max_workers" {
  description = "Maximum number of workers in worker pool"
  type        = number
  default     = 1
}

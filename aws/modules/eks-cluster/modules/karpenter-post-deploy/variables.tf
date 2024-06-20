variable "karpenter_node_role_name" {
	type = string
}

variable "node_pool_instance" {
  type = object({
    arch   = list(string) # "amd64"
    os     = list(string) # "linux"
    family = list(string) # "t3a"
    size   = list(string) # "xlarge"
  })
}

variable "node_group_name" {
  type = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}
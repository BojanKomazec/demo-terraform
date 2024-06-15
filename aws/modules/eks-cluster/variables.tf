variable "cluster" {
  description = "EKS cluster configuration"
  type = object({
    // "Name of the EKS cluster"
    name = string

    // "List of subnet IDs. Must be in at least two different availability zones."
    vpc_subnet_ids = list(string)
  })
}

variable "node_group" {
  description = "Node group configuration"
  type = object({
    // "Name of the EKS Node Group"
    name = string

    // "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT."
    capacity_type = string

    scaling_config = object({
      // "Desired number of worker nodes"
      desired_size = number

      // "Maximum number of worker nodes"
      max_size = number

      // "Minimum number of worker nodes"
      min_size = number
    })

    update_config = object({
      // "Desired max number of unavailable worker nodes during node group update."
      max_unavailable = number
    })

    // "Identifiers of EC2 Subnets to associate with the EKS Node Group."
    subnet_ids = list(string)

    // "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
    node_ami_type = string

    // "List of instance types associated with the EKS Node Group. Defaults to ['t3.medium']"
    node_instance_types = list(string)

    // "Disk size in GiB for worker nodes. Defaults to 50 for Windows, 20 all other node groups."
    node_disk_size = number
  })
}

variable "cluster_role" {
  description = "Cluster role configuration"
  type = object({
    // "Name of the IAM role that will be used by the EKS to manage cluster nodes"
    name = string

    // "Description of the IAM role that will be used by the EKS to manage cluster nodes"
    description = string
  })
}

variable "node_role" {
  description = "Node role configuration"
  type = object({
    // "Name of the IAM role that will be used by the cluster nodes to make AWS API calls"
    name = string

    // "Description of the IAM role that will be used by the cluster nodes to make AWS API calls"
    description = string
  })
}


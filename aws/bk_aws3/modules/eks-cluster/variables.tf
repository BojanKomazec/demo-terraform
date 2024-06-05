variable "cluster_role_name" {
    description = "Name of the IAM role that will be used by the EKS to manage cluster nodes"
    type = string
}

variable "cluster_role_description" {
    description = "Description of the IAM role that will be used by the EKS to manage cluster nodes"
    type = string
}

variable "cluster_name" {
    description = "Name of the EKS cluster"
    type = string
}

variable "node_role_name" {
    description = "Name of the IAM role that will be used by the cluster nodes to make AWS API calls"
    type = string
}

variable "node_role_description" {
    description = "Description of the IAM role that will be used by the cluster nodes to make AWS API calls"
    type = string
}

variable "node_group_name" {
    description = "Name of the EKS Node Group"
    type = string
}

variable "node_group_desired_size" {
    description = "Desired number of worker nodes"
    type = number
}

variable "node_group_max_size" {
    description = "Maximum number of worker nodes"
    type = number
}

variable "node_group_min_size" {
    description = "Minimum number of worker nodes"
    type = number
}

variable "node_ami_type" {
    description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
    type = string
}

variable "node_instance_types" {
    description = "List of instance types associated with the EKS Node Group. Defaults to ['t3.medium']"
    type = list(string)
}

variable "node_disk_size" {
    description = "Disk size in GiB for worker nodes. Defaults to 50 for Windows, 20 all other node groups."
    type = number
}

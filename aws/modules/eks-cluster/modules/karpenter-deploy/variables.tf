variable "aws_region" {
  description = "The AWS region."
  type        = string
}

variable "aws_environment" {
  description = "The AWS environment."
  type        = string
}

variable "aws_iam_profile" {
  type = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

# List of all subnets used in all node groups
variable "node_groups_subnet_ids" {
  description = "List of subnet ids used in all node groups in cluster."
  type        = list(string)
}

# variable "eks_cluster_security_group_id" {
#   description = "The (default) security group associated with and implicitly created by the EKS cluster."
#   type        = string
# }

# aws_eks_cluster.cluster.identity[0].oidc[0].issuer
# variable "eks_cluster_oidc_issuer_url" {
#   description = "The OIDC Issuer URL exposed on an EKS Cluster."
#   type        = string
# }

variable "node_group_name" {
  type = string
}

# aws_iam_role.node_group_role.name
variable "eks_cluster_node_group_role_name" {
  description = "The name of the IAM role associated with the EKS Node Group."
  type        = string
}

# aws_eks_cluster.cluster.endpoint
# variable "eks_cluster_endpoint" {
#   description = "The endpoint for the EKS cluster."
#   type        = string
# }

# aws_eks_cluster.cluster.id
# variable "eks_cluster_id" {
#   description = "The ID of the EKS cluster."
#   type        = string
# }

variable "karpenter_version" {
  type = string
}

variable "karpenter_namespace" {
  description = "EKS cluster namespace into which to install Karpenter"
  type = string
}


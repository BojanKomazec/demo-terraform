# TODO: Consider injecting only relevant attributes and removing this data
# source
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

# data "aws_eks_node_groups" "this" {
#   cluster_name = var.cluster_name
# }

# data "aws_eks_node_group" "this" {
#   for_each        = data.aws_eks_node_groups.this.names
#   cluster_name    = var.cluster_name
#   node_group_name = each.value
# }

data "aws_iam_role" "eks_cluster_node_group_role" {
  name = var.eks_cluster_node_group_role_name
}

# Identify current AWS Account.
data "aws_caller_identity" "account" {}

data "aws_eks_cluster_auth" "example" {
  name = "example"
}
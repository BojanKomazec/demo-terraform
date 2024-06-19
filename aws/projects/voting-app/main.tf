#
# In case we want to use all default (public) subnets.
#
# data "aws_vpc" "selected" {
#   default = true
# }

#
# If we know that there is only a single nondefault VPC and we want to use all
# subnets from it we can set default to false.
# If there is more than one nondefault VPC, we'd need to use one more
# parameter to uniquely identify it.
#
# data "aws_vpc" "selected" {
#   default = false
# }

# We can also filter out VPC by using its tags:
data "aws_vpc" "selected" {
  tags = {
    Environment = "Development"
  }
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name = "tag:Tier"
    values = [ "private" ]
  }
}

module "voting-app-eks-cluster" {
  source = "../../../modules/eks-cluster"

  cluster_role_name        = "eksClusterRole"
  cluster_role_description = "Amazon EKS - Cluster role"
  cluster_name             = "example-voting-app"
  node_role_name           = "eksNodeRole"
  node_role_description    = "IAM Role for EKS Node Group"
  node_group_name          = "demo-workers"
  node_group_desired_size  = 1 # 2
  node_group_max_size      = 10 # 2
  node_group_min_size      = 0 # 2
  node_group_capacity_type = "ON_DEMAND"
  node_group_update_max_unavailable = 1
  node_ami_type            = "AL2_x86_64"
  node_instance_types      = ["t2.medium"]
  node_disk_size           = 20
  cluster_vpc_subnet_ids   = data.aws_subnets.all.ids
  node_group_subnet_ids    = data.aws_subnets.private.ids
}

#
# How to move already created resources into new modules without destroying them?
#
# After moving resources to a new module we'll run:
# 1) terraform init (so the new module is installed)
# 2) terraform plan (to see what changes would take place)
# This output would contain something like:
#  # aws_iam_role.eks-cluster-role will be destroyed
#  # (because aws_iam_role.eks-cluster-role is not in configuration)
#  - resource "aws_iam_role" "eks-cluster-role" {
#  ...
#  }
#  ...
#  # module.voting-app-eks-cluster.aws_iam_role.eks-cluster-role will be created
#  + resource "aws_iam_role" "eks-cluster-role" {
#  ...
#  }
#
# In order to move this role into the new module without destroying it we need to
# add 'moved' block like this:
moved {
  from = aws_iam_role.eks-cluster-role
  to   = module.voting-app-eks-cluster.aws_iam_role.eks-cluster-role
}
# The next 'terraform plan' will contain this output:
#   # aws_iam_role.eks-cluster-role has moved to module.voting-app-eks-cluster.aws_iam_role.eks-cluster-role
#     resource "aws_iam_role" "eks-cluster-role" {
#         id                    = "eksClusterRole"
#         name                  = "eksClusterRole"
#         tags                  = {}
#         # (10 unchanged attributes hidden)
#     }
#
# After this we can do 'terraform apply'.


moved {
  from = aws_iam_role.eks_node_role
  to   = module.voting-app-eks-cluster.aws_iam_role.eks_node_role
}

moved {
  from = aws_iam_role_policy_attachment.eks_node_role-AmazonEC2ContainerRegistryReadOnly
  to   = module.voting-app-eks-cluster.aws_iam_role_policy_attachment.eks_node_role-AmazonEC2ContainerRegistryReadOnly
}

moved {
  from = aws_iam_role_policy_attachment.eks_node_role-AmazonEKSWorkerNodePolicy
  to   = module.voting-app-eks-cluster.aws_iam_role_policy_attachment.eks_node_role-AmazonEKSWorkerNodePolicy
}

moved {
  from = aws_iam_role_policy_attachment.eks_node_role-AmazonEKS_CNI_Policy
  to   = module.voting-app-eks-cluster.aws_iam_role_policy_attachment.eks_node_role-AmazonEKS_CNI_Policy
}
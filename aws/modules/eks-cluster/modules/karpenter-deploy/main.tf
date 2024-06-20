# https://karpenter.sh/docs/getting-started/migrating-from-cas/#add-tags-to-subnets-and-security-groups
# In our case we'll use only private subnets for node group so we'll add
# Karpenter-specific tags only to those subnets.

# Tagging all subnets used in all node groups
resource "aws_ec2_tag" "karpenter_subnets" {
  count = length(var.node_groups_subnet_ids)

  resource_id = var.node_groups_subnet_ids[count.index]
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Tagging default security group (associated with the EKS cluster)
# % aws eks describe-cluster --name <cluster_name> --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --profile terraform-dev --output text
# sg-02745bb8847f25a00
# This is Cluster security group. There are two other additional security groups associated with that EKS cluster.
# We need to add a tag but Cluster security group gets created by EKS during cluster creation.
#
resource "aws_ec2_tag" "karpenter_security_group" {
  resource_id = local.eks_cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}


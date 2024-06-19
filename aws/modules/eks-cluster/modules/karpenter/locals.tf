locals {

  # Obtain an account ID
  account_id = data.aws_caller_identity.account.account_id

  # node_group_names = [for ng in data.aws_eks_node_group.this : ng.node_group_name]

  # Command arguments for generating kube config and obtaining EKS token
  eks_auth_args = [
    "eks",
    "get-token",
    "--cluster-name",
    var.cluster_name,
    "--profile",
    # "${var.aws_iam_profile}-${var.aws_environment}",
    var.aws_iam_profile,
    "--region",
    var.aws_region
  ]

  # The OIDC Issuer URL exposed on an EKS Cluster.
  eks_cluster_oidc_issuer_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  # The (default) security group associated with and implicitly created by the EKS cluster.
  eks_cluster_security_group_id = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id

  eks_cluster_endpoint = data.aws_eks_cluster.this.endpoint

  eks_cluster_id = data.aws_eks_cluster.this.id

  map_roles = <<ROLES
- rolearn: ${data.aws_iam_role.eks_cluster_node_group_role.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${aws_iam_role.karpenter-node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
ROLES

}
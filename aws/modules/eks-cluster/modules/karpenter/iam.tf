resource "aws_iam_role" "karpenter-node" {
  name               = "KarpenterNodeRole-${var.cluster_name}"
  assume_role_policy = file("${path.module}/files/KarpenterNodeRoleTrustPolicy.json")
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

# data "aws_iam_policy_document" "karpenter_controller_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:karpenter:karpenter"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.this.arn]
#       type        = "Federated"
#     }
#   }
# }



# % aws eks describe-cluster --name <cluster_name> --query "cluster.identity.oidc.issuer" --profile terraform --output text
# https://oidc.eks.us-east-1.amazonaws.com/id/0BFFFA7CFCC5BD6E6C274B0F54660073
# In https://karpenter.sh/docs/getting-started/migrating-from-cas/:
# ${OIDC_ENDPOINT#*//} - this means: take the value of OIDC_ENDPOINT and remove everything up to and including the 
# first double slash (//). This is a bash parameter expansion.
# assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role_policy.json
# OIDC_ENDPOINT       = aws_eks_cluster.cluster.identity[0].oidc[0].issuer,
# AWS_ACCOUNT_ID = "123456789012",
# OIDC_ENDPOINT       = "https://oidc.eks.${var.aws_region}.amazonaws.com/id/${local.cluster_identity_oidc_issuer_id}",
#  "oidc.eks.us-east-1.amazonaws.com/id/0BFFFA7CFCC5BD6E6C274B0F54660073"
resource "aws_iam_role" "karpenter-controller" {
  name = "KarpenterControllerRole-${var.cluster_name}"
  assume_role_policy = templatefile("${path.module}/files/templates/KarpenterControllerRoleTrustPolicy.json.tftpl", {
    AWS_ACCOUNT_ID      = local.account_id,
    OIDC_ENDPOINT       = replace(local.eks_cluster_oidc_issuer_url, "https://", ""),
    KARPENTER_NAMESPACE = "kube-system",
  })
}

resource "aws_iam_policy" "karpenter-controller" {
  name = "KarpenterControllerPolicy-${var.cluster_name}"
  policy = templatefile(
    "${path.module}/files/templates/KarpenterControllerPolicy.json.tftpl", {
      AWS_ACCOUNT_ID = local.account_id,
      CLUSTER_NAME   = var.cluster_name,
      AWS_REGION     = var.aws_region,
    }
  )
}

resource "aws_iam_role_policy_attachment" "karpenter-controller-attach" {
  role       = aws_iam_role.karpenter-controller.name
  policy_arn = aws_iam_policy.karpenter-controller.arn
}


# resource "aws_iam_policy" "karpenter_controller" {
#   policy = file("${path.module}/files/KarpenterControllerTrustPolicy.json")
#   name   = "KarpenterController"
# }

# resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
#   role       = aws_iam_role.karpenter_controller.name
#   policy_arn = aws_iam_policy.karpenter_controller. arn
# }

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile"
  role = var.eks_cluster_node_group_role_name
}
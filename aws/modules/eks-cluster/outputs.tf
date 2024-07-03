output "node_group_role_name" {
  value = aws_iam_role.eks_node_role.name
}

# Kubernetes API server endpoint
output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

# Base64 encoded certificate data required to communicate with the cluster.
# Usually added to the certificate-authority-data section of the kubeconfig
# file for the cluster.
output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

# output "node_group_names" {
#   value = [for ng in aaws_eks_node_group.workers : ng.node_group_name]
# }

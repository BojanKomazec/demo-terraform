output "karpenter_helm_deployment" {
  value = {
    manifest = helm_release.karpenter.manifest
    metadata = helm_release.karpenter.metadata
    status   = helm_release.karpenter.status
  }
}

output "karpenter_node_role_name" {
  value = resource.aws_iam_role.karpenter-node.name
}
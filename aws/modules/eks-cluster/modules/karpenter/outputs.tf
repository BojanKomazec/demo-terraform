output "karpenter_helm_deployment" {
  value = {
    manifest = helm_release.karpenter.manifest
    metadata = helm_release.karpenter.metadata
    status   = helm_release.karpenter.status
  }
}
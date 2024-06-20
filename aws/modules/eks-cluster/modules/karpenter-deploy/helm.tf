# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
#
#╷
# Error: Kubernetes cluster unreachable: Get "https://FBA1D3570D004D2B1CEADC1145B2E928.yl4.eu-west-2.eks.amazonaws.com/version": dial tcp: lookup FBA1D3570D004D2B1CEADC1145B2E928.yl4.eu-west-2.eks.amazonaws.com on 127.0.0.53:53: no such host
#
resource "helm_release" "karpenter" {
  namespace        = var.karpenter_namespace
  create_namespace = true
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  # repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  # repository_password = data.aws_varecrpublic_authorization_token.token.password
  chart   = "karpenter"
  version = var.karpenter_version

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter-controller.arn
  }

  set {
    # name  = "settings.aws.clusterName"
    name  = "settings.clusterName"
    value = local.eks_cluster_id
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = local.eks_cluster_endpoint
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = "test-queue-name"
  }

  values = [
    <<-EOF
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: karpenter.sh/nodepool
              operator: DoesNotExist
            - key: eks.amazonaws.com/nodegroup
              operator: In
              values:
              - ${var.node_group_name}
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          - topologyKey: "kubernetes.io/hostname"
    EOF
  ]

  # depends_on = [ resource.kubernetes_manifest.karpenter_crd ]
  depends_on = [ resource.helm_release.karpenter_crd ]
}

# https://gallery.ecr.aws/karpenter/karpenter-crd
resource "helm_release" "karpenter_crd" {

  # (Required) Chart name to be installed. A path may be used.
  chart = "karpenter-crd"

  # (Required) Release name
  name = "karpenter-crd"

  # Namespace to install the release into.
  namespace = var.karpenter_namespace

  # Create the namespace if it does not exist.
  create_namespace = true

  # Repository where to locate the requested chart.
  repository = "oci://public.ecr.aws/karpenter"

  # Specify the exact chart version to install. If this is not specified, the
  # latest version is installed.
  version = var.karpenter_version
}
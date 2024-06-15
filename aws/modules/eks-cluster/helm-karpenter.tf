# The Helm provider is used to deploy software packages in Kubernetes.
#
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs
#
#
# Authentication
#
# The provider needs to be configured with the proper credentials before it can
# be used.
#
# In our case here, the Helm provider is getting its configuration explicitly,
# by supplying attributes to the provider block via Exec plugins.
#
# Some cloud providers have short-lived authentication tokens that can expire
# relatively quickly. To ensure the Kubernetes provider is receiving valid
# credentials, an exec-based plugin can be used to fetch a new token before
# initializing the provider. For example, on EKS, the command 'eks get-token'
# can be used.
#
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs#exec-plugins
#
provider "helm" {
  kubernetes {

    # BK added in order to fix error:
    # Error: Kubernetes cluster unreachable: the server has asked for the client to provide credentials
    config_path = "~/.kube/config"

    # (Optional) The hostname (in form of URI) of the Kubernetes API.
    host = aws_eks_cluster.this.endpoint

    # (Optional) PEM-encoded root certificates bundle for TLS authentication.
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)

    # (Optional) Configuration block to use an exec-based credential plugin,
    # e.g. call an external command to receive user credentials.
    exec {
      # (Required) API version to use when decoding the ExecCredentials
      # resource, e.g. client.authentication.k8s.io/v1beta1.
      api_version = "client.authentication.k8s.io/v1beta1"

      # (Optional) List of arguments to pass when executing the plugin.
      args = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name]

      # (Required) Command to execute.
      command = "aws"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "v0.16.3"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }

  set {
    name  = "clusterName"
    value = aws_eks_cluster.this.id
  }

  set {
    name  = "clusterEndpoint"
    value = aws_eks_cluster.this.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }

  depends_on = [aws_eks_node_group.workers]
}

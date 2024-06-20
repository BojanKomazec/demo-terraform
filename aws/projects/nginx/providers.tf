terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Configuration options
  profile = local.aws_iam_profile

  # London
  region = local.aws_region

  # This is necessary so that tags required for Karpenter can be applied to the vpc
  # without changes to the vpc wiping them out.
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging#ignoring-changes-in-individual-resources
  ignore_tags {
    key_prefixes = ["karpenter.sh/"]
  }
}

# Initiate helm provider
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
    # If not provided, the following error appears:
    # Error: Kubernetes cluster unreachable: the server has asked for the client to provide credentials
    # config_path = "~/.kube/config"

    # (Optional) The hostname (in form of URI) of the Kubernetes API.
    host = module.nginx-eks-cluster.endpoint

    # (Optional) PEM-encoded root certificates bundle for TLS authentication.
    cluster_ca_certificate = base64decode(module.nginx-eks-cluster.kubeconfig-certificate-authority-data)

    # (Optional) Configuration block to use an exec-based credential plugin,
    # e.g. call an external command to receive user credentials.
    exec {
      # (Required) API version to use when decoding the ExecCredentials
      # resource, e.g. client.authentication.k8s.io/v1beta1.
      api_version = "client.authentication.k8s.io/v1beta1"

      # (Optional) List of arguments to pass when executing the plugin.
      args = local.eks_auth_args

      # (Required) Command to execute.
      command = "aws"
    }
  }

  debug = true

  experiments {
    manifest = true
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started.html
#
# This provider allows managing all Kubernetes resources described in YAML files
# so we don't need to use kubectl CLI tool.
provider "kubernetes" {
  host                   = module.nginx-eks-cluster.endpoint
  cluster_ca_certificate = base64decode(module.nginx-eks-cluster.kubeconfig-certificate-authority-data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = local.eks_auth_args
    command     = "aws"
  }
}
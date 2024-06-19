locals {
  aws_region = "eu-west-2"

  # TODO: Use ${terraform.workspace}
  aws_environment = "development"
  cluster_name    = "nginx-cluster"
  aws_iam_profile = "terraform" # must be in ~/.aws/credentials

  eks_auth_args = [
    "eks",
    "get-token",
    "--cluster-name",
    local.cluster_name,
    "--profile",
    local.aws_iam_profile,
    "--region",
    local.aws_region
  ]

  node_group_name = "private-worker-nodes"
}
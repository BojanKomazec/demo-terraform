# We'll be using AWS managed AmazonEKSServicePolicy so this custom policy resource is not needed.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
# resource "aws_iam_policy" "eks_cluster_policy" {
#   #  (Optional, Forces new resource) Name of the policy. If omitted, Terraform will assign a random, unique name.
#   name = "eksClusterPolicy"
#   # (required) Policy document. This is a JSON formatted string.
#   # the original file is already JSON so no need to use jsonencode()
#   # Policy content was taken from: https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
#   policy = file("${path.module}/policies/eks_cluster_policy.json")
# }


# https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# ToDo: rename resource to "eks-cluster" as 'role' is redundant in the name.
resource "aws_iam_role" "eks-cluster-role" {
  # (Optional) Friendly name of the role. If omitted, Terraform will assign a random, unique name.
  name = var.cluster_role.name

  # (Optional)
  description = var.cluster_role.description

  # (required) Policy that grants an entity permission to assume the role.
  # assume_role_policy is very similar to but slightly different than a standard IAM
  # policy and cannot use an aws_iam_policy resource. However, it can use an
  # aws_iam_policy_document data source.
  # We can also use https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
  # This policy adds "AWS Service: eks" under "Trusted entities" for this role.
  assume_role_policy = file("${path.module}/policies/eks_cluster_trust_policy.json")

  # (Optional) Set of exclusive IAM managed policy ARNs to attach to the IAM role.
  # Configuring an empty set (i.e., managed_policy_arns = []) will cause Terraform
  # to remove all managed policy attachments.
  #
  # https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
  # Custom IAM policy (aws_iam_policy.eks_cluster_policy.arn) doesn't allow the legacy Cloud Provider to create load
  # balancers with Elastic Load Balancing. When attaching only this policy and then provisioning LoadBalancer
  # Kubernetes service, that service would be stuck with obtaining EXTERNAL-IP is in pending state.
  #
  # 'kubectl describe svc result-service' shows:
  #
  #   Type     Reason                  Age                 From                Message
  #   ----     ------                  ----                ----                -------
  #   Warning  SyncLoadBalancerFailed  4m5s                service-controller  Error syncing load balancer: failed to ensure load balancer: error describing subnets: "error listing AWS subnets: \"UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws:sts::47xxxx18:assumed-role/eksClusterRole/171xxxxx053 is not authorized to perform: ec2:DescribeSubnets because no identity-based policy allows the ec2:DescribeSubnets action\\n\\tstatus code: 403, request id: 8a39066d-2f88-4d2f-b45b-de41045edda9\""
  #
  # To prevent that the best is to use AWS managed AmazonEKSServicePolicy as recommended in the
  # document above and also here:
  # https://www.pulumi.com/ai/answers/67jdSMoe1ZpEeJkSNCBgUm/creating-eks-service-role-with-aws
  #
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#example-iam-role-for-eks-node-group
# It's going to be used by the regular node pool and not Karpenter.
resource "aws_iam_role" "eks_node_role" {
  name = var.node_role["name"]

  description = var.node_role["description"]

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}


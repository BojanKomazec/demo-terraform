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
resource "aws_iam_role" "eks-cluster-role" {
  # (Optional) Friendly name of the role. If omitted, Terraform will assign a random, unique name.
  name = var.cluster_role_name

  # (Optional)
  description = var.cluster_role_description

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
  #   Warning  SyncLoadBalancerFailed  4m5s                service-controller  Error syncing load balancer: failed to ensure load balancer: error describing subnets: "error listing AWS subnets: \"UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws:sts::471112786618:assumed-role/eksClusterRole/1716938688010985053 is not authorized to perform: ec2:DescribeSubnets because no identity-based policy allows the ec2:DescribeSubnets action\\n\\tstatus code: 403, request id: 8a39066d-2f88-4d2f-b45b-de41045edda9\""
  #
  # To prevent that the best is to use AWS managed AmazonEKSServicePolicy as recommended in the
  # document above and also here:
  # https://www.pulumi.com/ai/answers/67jdSMoe1ZpEeJkSNCBgUm/creating-eks-service-role-with-aws
  #
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_eks_cluster" "this" {
  # (required)  Name of the cluster.
  name = var.cluster_name

  # Desired Kubernetes master version. If you do not specify a value,
  # the latest available version at resource creation is used and no
  # upgrades will occur except those automatically triggered by EKS.
  # version = "1.16"

  # (Required) ARN of the IAM role that provides permissions for the
  # Kubernetes control plane to make calls to AWS API operations on your
  # behalf.
  role_arn = aws_iam_role.eks-cluster-role.arn

  # (Required) Configuration block for the VPC associated with your cluster.
  # Amazon EKS VPC resources have specific requirements to work properly with
  # Kubernetes.
  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  # BK: We need to be sure that EKS cluster role is ready before creating the cluster
  # But do we need this at all as role is already refernced in role_arn?
  # Can policy attachment take place after role gets ARN which can be referenced elsewhere?
#   depends_on = [
#     aws_iam_role.eks-cluster-role
#   ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#example-iam-role-for-eks-node-group
resource "aws_iam_role" "eks_node_role" {
  name = var.node_role_name

  description = var.node_role_description

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

resource "aws_eks_node_group" "workers" {
    # (Optional) Name of the EKS Node Group.
    node_group_name = var.node_group_name

    # (Required) Name of the EKS Cluster.
    cluster_name = aws_eks_cluster.this.name

    # (Required) Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Node Group.
    node_role_arn = aws_iam_role.eks_node_role.arn

    # (Required) Configuration block with scaling settings.
    # Auto-scaling.
    scaling_config {
        # (Required) Desired number of worker nodes.
        desired_size = var.node_group_desired_size

        # (Required) Maximum number of worker nodes.
        max_size = var.node_group_max_size

        # (Required) Minimum number of worker nodes.
        min_size = var.node_group_min_size
    }

    # (Required) Identifiers of EC2 Subnets to associate with the EKS Node Group.
    subnet_ids = data.aws_subnets.default.ids

    #
    # Node compute configuration
    # These properties cannot be changed after the Node Group is created.
    #

    # (Optional) Type of Amazon Machine Image (AMI) associated with the EKS Node Group.
    # https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType
    ami_type = var.node_ami_type

    # (Optional) List of instance types associated with the EKS Node Group. Defaults to ["t3.medium"].
    # "t2.micro" is available in free tier BUT
    # https://stackoverflow.com/questions/75026935/pod-creation-in-eks-cluster-fails-with-failedscheduling-error
    # https://github.com/awslabs/amazon-eks-ami/blob/pinned-cache/files/eni-max-pods.txt
    instance_types = var.node_instance_types

    # (Optional) Disk size in GiB for worker nodes. Defaults to 50 for Windows, 20 all other node groups.
    disk_size = var.node_disk_size
}

# NOTE: I only had success adding and activating this add-on via resource "aws_guardduty_detector_feature".
# resource "aws_eks_addon" "guardduty" {
#   # (Required) Name of the EKS Cluster.
#   cluster_name                = aws_eks_cluster.this.name

#   # (Required) Name of the EKS add-on.
#   # To get all available addons execute:
#   # $ aws eks describe-addon-versions --output table --query 'addons[].{Name: addonName, Publisher: publisher}'
#   addon_name                  = "aws-guardduty-agent"

#   # (Optional) The version of the EKS add-on. The version must match one of the versions returned by describe-addon-versions.
#   # To get the latest version execute:
#   # $ aws eks describe-addon-versions --output table --addon-name=aws-guardduty-agent --query 'addons[].{Name: addonName, Publisher: publisher, Version: addonVersions[0].addonVersion}'
#   addon_version               = "v1.6.1-eksbuild.1"

#   # (Optional) How to resolve field value conflicts for an Amazon EKS add-on if you've changed a value from the Amazon EKS default value.
#   # Valid values are NONE, OVERWRITE, and PRESERVE.
#   resolve_conflicts_on_update = "OVERWRITE"
# }
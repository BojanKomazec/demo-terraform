resource "aws_eks_cluster" "this" {
  # (required)  Name of the cluster.
  name = var.cluster["name"]

  # Desired Kubernetes master version. If you do not specify a value,
  # the latest available version at resource creation is used and no
  # upgrades will occur except those automatically triggered by EKS.
  # version = "1.22"

  # (Required) ARN of the IAM role that provides permissions for the
  # Kubernetes control plane to make calls to AWS API operations on your
  # behalf.
  role_arn = aws_iam_role.eks-cluster-role.arn

  # (Required) Configuration block for the VPC associated with your cluster.
  # Amazon EKS VPC resources have specific requirements to work properly with
  # Kubernetes.
  vpc_config {
    # (Required) List of subnet IDs. Must be in at least two different
    # availability zones. Amazon EKS creates cross-account elastic network
    # interfaces in these subnets to allow communication between your worker
    # nodes and the Kubernetes control plane.
    subnet_ids = var.cluster["vpc_subnet_ids"]

    # Is Amazon EKS API server private endpoint enabled? Default is false.
    endpoint_private_access = false

    # Is Amazon EKS API server public endpoint enabled? Default is true.
    endpoint_public_access = true

    # List of CIDR blocks. Indicates which CIDR blocks can access the Amazon
    # EKS public API server endpoint when enabled. EKS defaults this to a list
    # with 0.0.0.0/0
    public_access_cidrs = ["0.0.0.0/0"]
  }

  # (Optional) Configuration block for the access config associated with the
  # cluster.
  access_config {
    # (Optional) The authentication mode for the cluster. Valid values are
    # CONFIG_MAP, API or API_AND_CONFIG_MAP.
    # If you create a cluster by using the EKS API, AWS SDKs, or
    # AWS CloudFormation, the default is CONFIG_MAP. If you create the cluster
    # by using the AWS Management Console, the default value is
    # API_AND_CONFIG_MAP
    authentication_mode                         = "API_AND_CONFIG_MAP"

    # (Optional) Whether or not to bootstrap the access config values to the
    # cluster. Default is true.
    # Specifies whether or not the cluster creator IAM principal was set as a
    # cluster admin access entry during cluster creation time.
    # If this is set to false (or config map gets overwritten later so this
    # prinicpal is removed) the following error is shown in AWS Console when
    # principal tries to view cluster resources:
    # "Your current user or role does not have access to Kubernetes objects on
    # this EKS cluster"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS
  # Cluster handling. Otherwise, EKS will not be able to properly delete EKS
  # managed EC2 infrastructure such as Security Groups.
  # BK: We need to be sure that EKS cluster role is ready before creating the
  # cluster
  # But do we need this at all as role is already refernced in role_arn?
  # Can policy attachment take place after role gets ARN which can be referenced
  # elsewhere?
  #   depends_on = [
  #     aws_iam_role.eks-cluster-role
  #   ]
}

resource "aws_eks_node_group" "workers" {
  # (Optional) Name of the EKS Node Group.
  node_group_name = var.node_group["name"]

  # (Required) Name of the EKS Cluster.
  cluster_name = aws_eks_cluster.this.name

  # (Required) Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Node Group.
  node_role_arn = aws_iam_role.eks_node_role.arn

  # (Optional) Type of capacity associated with the EKS Node Group.
  # Valid values: ON_DEMAND, SPOT.
  capacity_type = var.node_group["capacity_type"]

  # (Required) Configuration block with scaling settings.
  # AWS Auto-scaling Group properties.
  scaling_config {
    # (Required) Desired number of worker nodes.
    desired_size = var.node_group["scaling_config"]["desired_size"]

    # (Required) Maximum number of worker nodes.
    max_size = var.node_group["scaling_config"]["max_size"]

    # (Required) Minimum number of worker nodes.
    min_size = var.node_group["scaling_config"]["min_size"]
  }

  # (Optional) Update configuration.
  update_config {
    # (Optional) Desired max number of unavailable worker nodes during node
    # group update.
    max_unavailable = var.node_group["update_config"]["max_unavailable"]
  }

  # (Required) Identifiers of EC2 Subnets to associate with the EKS Node Group.
  subnet_ids = var.node_group["subnet_ids"]

  #
  # Node compute configuration
  # These properties cannot be changed after the Node Group is created.
  #

  # (Optional) Type of Amazon Machine Image (AMI) associated with the EKS Node Group.
  # https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType
  ami_type = var.node_group["node_ami_type"]

  # (Optional) List of instance types associated with the EKS Node Group. Defaults to ["t3.medium"].
  # "t2.micro" is available in free tier BUT
  # https://stackoverflow.com/questions/75026935/pod-creation-in-eks-cluster-fails-with-failedscheduling-error
  # https://github.com/awslabs/amazon-eks-ami/blob/pinned-cache/files/eni-max-pods.txt
  instance_types = var.node_group["node_instance_types"]

  # (Optional) Disk size in GiB for worker nodes. Defaults to 50 for Windows, 20 all other node groups.
  disk_size = var.node_group["node_disk_size"]

  # (Optional) Kubernetes version. Defaults to EKS Cluster Kubernetes version.
  # version = "1.22"

  # labels = {
  #   role = "general"
  # }

  depends_on = [
    resource.aws_iam_role_policy_attachment.eks_node_role-AmazonEC2ContainerRegistryReadOnly,
    resource.aws_iam_role_policy_attachment.eks_node_role-AmazonEKS_CNI_Policy,
    resource.aws_iam_role_policy_attachment.eks_node_role-AmazonEKSWorkerNodePolicy
  ]

  # Allow external changes without Terraform plan difference
  # lifecycle {
  #   ignore_changes = [scaling_config[0].desired_size]
  # }
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
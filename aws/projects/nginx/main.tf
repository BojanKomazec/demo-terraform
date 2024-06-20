module "nginx-vpc" {
  source = "../../modules/vpc"

  vpc = {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name        = "k8s-nginx"
      Environment = "${local.aws_environment}"
    }
  }

  # There are 3 avalilability zones in the eu-west-2 region.
  # We'll provison one public and one private subnet in each AZ.
  #
  # TODO: AZ names should be deducted automatically from the given region and so
  # this array of subnets should be created programmatically.
  subnets = [
    {
      cidr_block              = "10.0.0.0/24"
      availability_zone       = "eu-west-2a"
      map_public_ip_on_launch = true
      tags = {
        Name        = "public-eu-west-2a"
        Tier        = "public"
        Environment = "${local.aws_environment}"
        Owner       = ""
      }
    },
    {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "eu-west-2b"
      map_public_ip_on_launch = true
      tags = {
        Name        = "public-eu-west-2b"
        Tier        = "public"
        Environment = "${local.aws_environment}"
        Owner       = ""
      }
    },
    {
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "eu-west-2c"
      map_public_ip_on_launch = true
      tags = {
        Name        = "public-eu-west-2c"
        Tier        = "public"
        Environment = "${local.aws_environment}"
        Owner       = ""
      }
    },
    {
      cidr_block              = "10.0.3.0/24"
      availability_zone       = "eu-west-2a"
      map_public_ip_on_launch = false
      tags = {
        Name        = "private-eu-west-2a"
        Tier        = "private"
        Environment = "${local.aws_environment}"
        Owner       = ""
      }
    },
    {
      cidr_block              = "10.0.4.0/24"
      availability_zone       = "eu-west-2b"
      map_public_ip_on_launch = false
      tags = {
        Name        = "private-eu-west-2b"
        Tier        = "private"
        Environment = "${local.aws_environment}"
        Owner       = ""
      }
    },
    {
      cidr_block              = "10.0.5.0/24"
      availability_zone       = "eu-west-2c"
      map_public_ip_on_launch = false
      tags = {
        Name        = "private-eu-west-2c"
        Tier        = "private"
        Environment = "${local.aws_environment}"
        Owner       = ""
      }
    },
  ]

  igw = {
    tags = {
      Name = "k8s-vpc-nginx"
    }
  }

  nat_gw = {
    tags = {
      Name = "k8s-nat-nginx"
    }
  }
}

module "nginx-eks-cluster" {
  source = "../../modules/eks-cluster"

  cluster = {
    name = local.cluster_name

    # Nice example of https://developer.hashicorp.com/terraform/language/modules/develop/composition
    vpc_subnet_ids = module.nginx-vpc.subnet_ids
  }

  node_group = {
    name = local.node_group_name
    scaling_config = {
      desired_size = 1  # 2
      max_size     = 10 # 2
      min_size     = 0  # 2
    }
    capacity_type = "ON_DEMAND"
    update_config = {
      max_unavailable = 1
    }
    node_ami_type       = "AL2_x86_64"
    node_instance_types = ["t2.medium"]
    node_disk_size      = 20
    subnet_ids          = module.nginx-vpc.private_subnet_ids
  }

  cluster_role = {
    name        = "eksClusterRole-${local.cluster_name}"
    description = "Amazon EKS - Cluster role"
  }

  node_role = {
    name        = "eksNodeRole-${local.cluster_name}"
    description = "IAM Role for EKS Node Group"
  }
}

module "nginx-eks-karpenter-deploy" {
  source = "../../modules/eks-cluster/modules/karpenter-deploy"

  aws_region                       = local.aws_region
  aws_environment                  = local.aws_environment
  aws_iam_profile                  = "terraform"
  cluster_name                     = local.cluster_name
  karpenter_version                = "0.37.0"
  karpenter_namespace              = "kube-system"
  node_group_name                  = local.node_group_name
  node_groups_subnet_ids           = module.nginx-vpc.private_subnet_ids
  eks_cluster_node_group_role_name = module.nginx-eks-cluster.node_group_role_name

  depends_on = [module.nginx-eks-cluster]
}

module "nginx-eks-karpenter-post-deploy" {
  # Provisioning Karpenter for the first time is a two-step process.
  # For the first 'terraform apply', omit provisioning this module.
  # Then execute 'terraform apply' again with this module included.
  count = 0
  source = "../../modules/eks-cluster/modules/karpenter-post-deploy"
  karpenter_node_role_name = module.nginx-eks-karpenter-deploy.karpenter_node_role_name

  node_pool_instance = {
    arch   = ["amd64"]
    os     = ["linux"]
    family = ["t2"]
    size   = ["medium"]
  }

  node_group_name                  = local.node_group_name
  cluster_name                     = local.cluster_name
}

# output "karpenter_node_pool_yaml_content" {
#   value = module.nginx-eks-karpenter-post-deploy[0].karpenter_node_pool_yaml_content
# }

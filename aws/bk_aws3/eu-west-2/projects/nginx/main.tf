locals {
  cluster_name = "nginx-cluster"
}

module "nginx-virtual-network" {
  source = "../../../../modules/virtual-network"

  vpc = {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name        = "k8s-nginx"
      Environment = "development"
    }
  }

  subnets = [
    {
      cidr_block              = "10.0.0.0/24"
      availability_zone       = "eu-west-2a"
      map_public_ip_on_launch = true
      tags = {
        Name        = "public-eu-west-2a"
        Tier        = "public"
        Environment = "development"
        Owner       = ""
      }
      optional_tags = {
        "kubernetes.io/role/internal-elb"             = "1"
        "kubernetes.io/cluster/${local.cluster_name}" = "owned"
      }
    },
    {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "eu-west-2b"
      map_public_ip_on_launch = true
      tags = {
        Name        = "public-eu-west-2b"
        Tier        = "public"
        Environment = "development"
        Owner       = ""
      }
      optional_tags = {
        "kubernetes.io/role/internal-elb"             = "1"
        "kubernetes.io/cluster/${local.cluster_name}" = "owned"
      }
    },
    {
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "eu-west-2c"
      map_public_ip_on_launch = true
      tags = {
        Name        = "public-eu-west-2c"
        Tier        = "public"
        Environment = "development"
        Owner       = ""
      }
      optional_tags = {
        "kubernetes.io/role/internal-elb"             = "1"
        "kubernetes.io/cluster/${local.cluster_name}" = "owned"
      }
    },
    {
      cidr_block              = "10.0.3.0/24"
      availability_zone       = "eu-west-2a"
      map_public_ip_on_launch = false
      tags = {
        Name        = "private-eu-west-2a"
        Tier        = "private"
        Environment = "development"
        Owner       = ""
      }
      optional_tags = {
        "kubernetes.io/role/internal-elb"             = "1"
        "kubernetes.io/cluster/${local.cluster_name}" = "owned"
      }
    },
    {
      cidr_block              = "10.0.4.0/24"
      availability_zone       = "eu-west-2b"
      map_public_ip_on_launch = false
      tags = {
        Name        = "private-eu-west-2b"
        Tier        = "private"
        Environment = "development"
        Owner       = ""
      }
      optional_tags = {
        "kubernetes.io/role/internal-elb"             = "1"
        "kubernetes.io/cluster/${local.cluster_name}" = "owned"
      }
    },
    {
      cidr_block              = "10.0.5.0/24"
      availability_zone       = "eu-west-2c"
      map_public_ip_on_launch = false
      tags = {
        Name        = "private-eu-west-2c"
        Tier        = "private"
        Environment = "development"
        Owner       = ""
      }
      optional_tags = {
        "kubernetes.io/role/internal-elb"             = "1"
        "kubernetes.io/cluster/${local.cluster_name}" = "owned"
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
  source = "../../../../modules/eks-cluster"

  cluster = {
    name = local.cluster_name

    # Nice example of https://developer.hashicorp.com/terraform/language/modules/develop/composition
    vpc_subnet_ids = module.nginx-virtual-network.subnet_ids
  }

  node_group = {
    name = "private-worker-nodes"
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
    subnet_ids          = module.nginx-virtual-network.private_subnet_ids
  }

  cluster_role = {
    name        = "eksClusterRole"
    description = "Amazon EKS - Cluster role"
  }

  node_role = {
    name        = "eksNodeRole"
    description = "IAM Role for EKS Node Group"
  }
}

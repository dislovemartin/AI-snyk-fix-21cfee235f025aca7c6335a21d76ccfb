provider "aws" {
  region = "us-west-2"  # Oregon region - best latency and availability for West Coast
}

module "vpc" {
  source = "./modules/vpc"

  cidr_block          = "10.0.0.0/16"  # Large CIDR block for future growth
  vpc_name            = "ai-platform-vpc"
  public_subnet_count = 3  # One subnet per AZ for high availability
}

resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "cluster" {
  name     = "ai-platform-cluster"
  role_arn = aws_iam_role.eks_role.arn
  version  = "1.28"  # Matching your K8s version from versions.conf

  vpc_config {
    subnet_ids = module.vpc.public_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}

resource "aws_autoscaling_group" "eks_nodes" {
  name                = "eks-node-group"
  desired_capacity    = 3
  max_size           = 15  # Increased for better scaling
  min_size           = 2   # Ensure high availability
  vpc_zone_identifier = module.vpc.public_subnet_ids
  launch_configuration = aws_launch_configuration.eks_nodes.id

  tag {
    key                 = "Name"
    value              = "eks-node"
    propagate_at_launch = true
  }

  # Enable instance refresh for rolling updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 66
    }
  }
}
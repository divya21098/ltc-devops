resource "aws_vpc" "main"{
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
}


resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/20"
  availability_zone = "us-west-1c"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "subnet-2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.16.0/20"
  availability_zone = "us-west-1b"
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
  
}
resource "aws_route_table" "rtab" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block = "10.0.0.0/24"
    gateway_id = "local"
  }
}
resource "aws_route_table_association" "subnet_1_association"{
    subnet_id = aws_subnet.subnet-1.id
    route_table_id = aws_route_table.rtab.id
}
resource "aws_route_table_association" "subnet_2_association"{
    subnet_id = aws_subnet.subnet-2.id
    route_table_id = aws_route_table.rtab.id
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-k8"
  cluster_version = "1.31"

  bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # Optional
  cluster_endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = aws_vpc.main.id
  subnet_ids               = [aws_subnet.subnet-1.id,aws_subnet.subnet-2.id]
  control_plane_subnet_ids = [aws_subnet.subnet-1.id,aws_subnet.subnet-2.id]

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["t2.medium"]

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
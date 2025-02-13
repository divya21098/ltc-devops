
# resource "aws_vpc" "main"{
#     cidr_block = "10.0.0.0/16"
#     enable_dns_hostnames = true
# }


# resource "aws_subnet" "subnet-1" {
#   vpc_id = aws_vpc.main.id
#   cidr_block = "10.0.0.0/20"
#   availability_zone = "us-west-1c"
#   map_public_ip_on_launch = true
# }
# resource "aws_subnet" "subnet-2" {
#   vpc_id = aws_vpc.main.id
#   cidr_block = "10.0.16.0/20"
#   availability_zone = "us-west-1b"
#   map_public_ip_on_launch = true
# }
# resource "aws_internet_gateway" "igw" {
#     vpc_id = aws_vpc.main.id
  
# }
# resource "aws_route_table" "rtab" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
#   route {
#     cidr_block = "10.0.0.0/16"
#     gateway_id = "local"
#   }
# }
# resource "aws_route_table_association" "subnet_1_association"{
#     subnet_id = aws_subnet.subnet-1.id
#     route_table_id = aws_route_table.rtab.id
# }
# resource "aws_route_table_association" "subnet_2_association"{
#     subnet_id = aws_subnet.subnet-2.id
#     route_table_id = aws_route_table.rtab.id
# }
# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 20.0"

#   cluster_name    = "my-cluster"
#   cluster_version = "1.31"

#   bootstrap_self_managed_addons = false
#   cluster_addons = {
#     coredns                = {}
#     eks-pod-identity-agent = {}
#     kube-proxy             = {}
#     vpc-cni                = {}
#   }

#   # Optional
#   cluster_endpoint_public_access = true

#   # Optional: Adds the current caller identity as an administrator via cluster access entry
#   enable_cluster_creator_admin_permissions = true

#   vpc_id                   = aws_vpc.main.id
#   subnet_ids               = [aws_subnet.subnet-1.id,aws_subnet.subnet-2.id]
#   control_plane_subnet_ids = [aws_subnet.subnet-1.id,aws_subnet.subnet-2.id]

#   eks_managed_node_groups = {
#     example = {
#       # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
#       instance_types = ["t2.medium"]

#       min_size     = 1
#       max_size     = 1
#       desired_size = 1
#     }
#   }

#   tags = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids      = module.vpc.private_subnets

  enable_irsa = true

  tags = {
    cluster = "demo"
  }

  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {

    node_group = {
      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "all_worker_mgmt_ingress" {
  description       = "allow inbound traffic from eks"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  security_group_id = aws_security_group.all_worker_mgmt.id
  type              = "ingress"
  cidr_blocks = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

resource "aws_security_group_rule" "all_worker_mgmt_egress" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.all_worker_mgmt.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.0"
#     }
#   }
# }

# provider "aws" {
#   region = "us-east-1"
# }

# # Create our own VPC (since the default VPC has no subnets)
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = "my-vpc"
#   }
# }

# # Create a public subnet inside it
# resource "aws_subnet" "main" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "my-subnet"
#   }
# }

# # Internet gateway so the instance can reach the internet
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "my-igw"
#   }
# }

# # Route table sending outbound traffic to the internet gateway
# resource "aws_route_table" "main" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }

#   tags = {
#     Name = "my-rt"
#   }
# }

# resource "aws_route_table_association" "main" {
#   subnet_id      = aws_subnet.main.id
#   route_table_id = aws_route_table.main.id
# }

# # Look up the latest Amazon Linux 2023 AMI
# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-*-x86_64"]
#   }
# }

# resource "aws_security_group" "main" {
#   name        = "my-sg"
#   description = "Security group for EC2 instance"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_instance" "my_ec2" {
#   ami                    = data.aws_ami.amazon_linux.id
#   instance_type          = "t3.micro"
#   subnet_id              = aws_subnet.main.id
#   vpc_security_group_ids = [aws_security_group.main.id]

#   tags = {
#     Name = "my-ec2-instance"
#   }

#   lifecycle {
#     precondition {
#       condition     = aws_security_group.main.id != ""
#       error_message = "Security group must be created before creating EC2 instances."
#     }
#   }
# }
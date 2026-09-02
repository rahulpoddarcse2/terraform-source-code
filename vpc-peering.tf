# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# provider "aws" {
#   region = "ap-south-1"
# }

# # ---------------------------------------------------
# # VPC 1
# # ---------------------------------------------------
# resource "aws_vpc" "myvpc" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = "MyVPC"
#   }
# }

# resource "aws_subnet" "public_subnet" {
#   vpc_id                  = aws_vpc.myvpc.id
#   cidr_block              = "10.0.1.0/24"

#   tags = {
#     Name = "public-subnet"
#   }
# }

# # Internet Gateway so the public subnet can actually reach/be reached from the internet
# resource "aws_internet_gateway" "myvpc_igw" {
#   vpc_id = aws_vpc.myvpc.id

#   tags = {
#     Name = "myvpc-igw"
#   }
# }

# # ---------------------------------------------------
# # VPC 2  (CIDR must NOT overlap with VPC 1 for peering to work)
# # ---------------------------------------------------
# resource "aws_vpc" "dostvpc" {
#   cidr_block           = "10.1.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = "dostvpc"
#   }
# }

# resource "aws_subnet" "private_subnet" {
#   vpc_id     = aws_vpc.dostvpc.id
#   cidr_block = "10.1.2.0/24"

#   tags = {
#     Name = "private-subnet"
#   }
# }

# # ---------------------------------------------------
# # VPC Peering Connection
# # ---------------------------------------------------
# resource "aws_vpc_peering_connection" "peer" {
#   vpc_id      = aws_vpc.myvpc.id
#   peer_vpc_id = aws_vpc.dostvpc.id
#   auto_accept = true

#   tags = {
#     Name = "myvpc-to-dostvpc"
#   }
# }

# # ---------------------------------------------------
# # Route table for VPC 1 (public subnet)
# # Handles BOTH internet access (via IGW) and peering to VPC 2
# # ---------------------------------------------------
# resource "aws_route_table" "myvpc_rt" {
#   vpc_id = aws_vpc.myvpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myvpc_igw.id
#   }

#   route {
#     cidr_block                = aws_vpc.dostvpc.cidr_block
#     vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
#   }

#   tags = {
#     Name = "myvpc-rt"
#   }
# }

# resource "aws_route_table_association" "public_subnet_assoc" {
#   subnet_id      = aws_subnet.public_subnet.id
#   route_table_id = aws_route_table.myvpc_rt.id
# }

# # ---------------------------------------------------
# # Route table for VPC 2 (private subnet)
# # Only gets a route back to VPC 1 over the peering connection — no internet route
# # ---------------------------------------------------
# resource "aws_route_table" "dostvpc_rt" {
#   vpc_id = aws_vpc.dostvpc.id

#   route {
#     cidr_block                = aws_vpc.myvpc.cidr_block
#     vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
#   }

#   tags = {
#     Name = "dostvpc-rt"
#   }
# }

# resource "aws_route_table_association" "private_subnet_assoc" {
#   subnet_id      = aws_subnet.private_subnet.id
#   route_table_id = aws_route_table.dostvpc_rt.id
# }

# # ---------------------------------------------------
# # Security Group for the instance (SSH + all traffic from the peered VPC)
# # ---------------------------------------------------
# resource "aws_security_group" "instance_sg" {
#   name        = "myvpc-instance-sg"
#   description = "Allow SSH from anywhere and all traffic from the peered VPC"
#   vpc_id      = aws_vpc.myvpc.id

#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Tighten this to your own IP in production
#   }

#   ingress {
#     description = "All traffic from peered VPC"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = [aws_vpc.dostvpc.cidr_block]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "myvpc-instance-sg"
#   }
# }

# # ---------------------------------------------------
# # EC2 Instance (placed inside the public subnet of VPC 1)
# # ---------------------------------------------------
# resource "aws_instance" "my_instance" {
#   ami                    = "ami-01a00762f46d584a1" # Replace with a valid AMI ID for ap-south-1
#   instance_type          = "t3.micro"
#   subnet_id              = aws_subnet.public_subnet.id
#   vpc_security_group_ids = [aws_security_group.instance_sg.id]

#   tags = {
#     Name = "MyInstance"
#   }
# }

# # ---------------------------------------------------
# # Outputs
# # ---------------------------------------------------
# output "instance_public_ip" {
#   value = aws_instance.my_instance.public_ip
# }

# output "myvpc_id" {
#   value = aws_vpc.myvpc.id
# }

# output "dostvpc_id" {
#   value = aws_vpc.dostvpc.id
# }

# output "peering_connection_id" {
#   value = aws_vpc_peering_connection.peer.id
# }
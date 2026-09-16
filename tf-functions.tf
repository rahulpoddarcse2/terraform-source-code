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

# # -----------------------------
# # VPC 1 (Requester)
# # -----------------------------
# resource "aws_vpc" "vpc_a" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "vpc-a"
#   }
# }

# # -----------------------------
# # VPC 2 (Accepter)
# # -----------------------------
# resource "aws_vpc" "vpc_b" {
#   cidr_block = "10.1.0.0/16"
#   tags = {
#     Name = "vpc-b"
#   }
# }

# # -----------------------------
# # Step 1: Peering connection banao
# # -----------------------------
# resource "aws_vpc_peering_connection" "peer" {
#   vpc_id      = aws_vpc.vpc_a.id
#   peer_vpc_id = aws_vpc.vpc_b.id
#   auto_accept = true   # dono VPC same AWS account mein hain toh auto-accept ho sakta hai

#   tags = {
#     Name = "vpc-a-to-vpc-b"
#   }
# }

# # -----------------------------
# # Step 2: Route tables update karo (dono taraf se)
# # -----------------------------

# # VPC A ka route table - VPC B tak jaane ka rasta batao
# resource "aws_route_table" "route_table_a" {
#   vpc_id = aws_vpc.vpc_a.id

#   route {
#     cidr_block                = aws_vpc.vpc_b.cidr_block
#     vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
#   }

#   tags = {
#     Name = "rt-vpc-a"
#   }
# }

# # VPC B ka route table - VPC A tak jaane ka rasta batao
# resource "aws_route_table" "route_table_b" {
#   vpc_id = aws_vpc.vpc_b.id

#   route {
#     cidr_block                = aws_vpc.vpc_a.cidr_block
#     vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
#   }

#   tags = {
#     Name = "rt-vpc-b"
#   }
# }

# output "name" {
#     value = aws_vpc_peering_connection.peer.id
  
# }
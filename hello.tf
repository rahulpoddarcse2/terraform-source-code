# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.0"
#     }
#   }
# }
#  provider "aws" {
#     region = "ap-south-1"
#   }


# resource "aws_vpc" "myvpc" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "MyVPC"
#   }
# }

# resource "aws_subnet" "public-subnet" {
#   vpc_id            = aws_vpc.myvpc.id
#   cidr_block        = "10.0.1.0/24"
#   tags = {
#     Name = "MySubnet"
#   }
# }
# resource "aws_subnet" "private-subnet" {
#   vpc_id     = aws_vpc.myvpc.id
#   cidr_block = "10.0.2.0/24"
#   tags = {
#     Name = "new"
#   }
# }
# resource "aws_internet_gateway" "my-igw"{
#     vpc_id=aws_vpc.myvpc.id
#     tags = {
#         Name = "MyInternetGateway"
#     }
# }
# resource aws_route_table "my-route-table" {
#   vpc_id = aws_vpc.myvpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.my-igw.id
#   }
#   tags = {
#     Name = "MyRouteTable"
#   }
# }
# data "aws_ami" "latest_amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-*-x86_64"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# data "aws_ssm_parameter" "latest_amazon_linux" {
#   name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
# }

# resource "aws_instance" "my-instance" {
#   ami           = data.aws_ssm_parameter.latest_amazon_linux.value
#   instance_type = "t3.micro"
#   subnet_id     = aws_subnet.public-subnet.id
# }
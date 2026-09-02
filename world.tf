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

# resource "aws_vpc" "myvpc" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "MyVPC"
#   }
# }

# resource "aws_subnet" "public_subnet" {
#   vpc_id                  = aws_vpc.myvpc.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = "ap-south-1a"
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "public-subnet"
#   }
# }

# resource "aws_subnet" "private_subnet" {
#   vpc_id            = aws_vpc.myvpc.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone = "ap-south-1b"
#   tags = {
#     Name = "private-subnet"
#   }
# }

# resource "aws_internet_gateway" "my_igw" {
#   vpc_id = aws_vpc.myvpc.id
#   tags = {
#     Name = "MyInternetGateway"
#   }
# }

# resource "aws_route_table" "my_route_table" {
#   vpc_id = aws_vpc.myvpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.my_igw.id
#   }

#   tags = {
#     Name = "MyRouteTable"
#   }
# }

# resource "aws_route_table_association" "public_assoc" {
#   subnet_id      = aws_subnet.public_subnet.id
#   route_table_id = aws_route_table.my_route_table.id
# }

# resource "aws_security_group" "web_sg" {
#   name   = "web-sg"
#   vpc_id = aws_vpc.myvpc.id

#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "web-sg"
#   }
# }

# data "aws_ssm_parameter" "latest_amazon_linux" {
#   name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
# }

# resource "aws_instance" "my_instance" {
#   ami                    = data.aws_ssm_parameter.latest_amazon_linux.value
#   instance_type           = "t3.micro"
#   subnet_id               = aws_subnet.public_subnet.id
#   vpc_security_group_ids  = [aws_security_group.web_sg.id]

#   user_data = <<-EOF
#               #!/bin/bash
#               dnf update -y
#               dnf install -y nginx
#               systemctl enable nginx
#               systemctl start nginx
#               EOF

#   tags = {
#     Name = "WORLD"
#   }
# }

# output "instance_public_ip" {
#   value = aws_instance.my_instance.public_ip
# }
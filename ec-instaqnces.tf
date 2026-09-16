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
# resource "aws_instance" "my_ec2" {
#   ami           = "ami-01a00762f46d584a1"
#   instance_type = "t2.micro"
#   count         = 4
#   tags = {
#     Name = "my-ec2-instance-${count.index}"
#   }
# }

# resource "aws_subnet" "my_subnet" {
#   vpc_id     = aws_vpc.my_vpc.id
#   cidr_block = "10.0.${count.index}.0/24"
#   count      = 2
#   tags = {
#     Name = "my-subnet-${count.index}"
#   }
# }

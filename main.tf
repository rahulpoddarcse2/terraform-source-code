terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.60.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "random_id" "rand_id" {
  byte_length = 8
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "new-1"
  }
}

# Private Subnet
resource "aws_subnet" "private-subnet" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = "ap-south-1a"
  tags = {
    Name = "private subnet"
  }
}

# Public Subnet
resource "aws_subnet" "public-subnet" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.my_vpc.id
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-igw"
  }
}

# Routing Table (public)
resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public-sub" {
  route_table_id = aws_route_table.my-rt.id
  subnet_id      = aws_subnet.public-subnet.id
}

# Security Group for the instance
resource "aws_security_group" "instance-sg" {
  name        = "myserver-sg-${random_id.rand_id.hex}"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "myserver-sg"
  }
}

resource "aws_instance" "myserver" {
  ami                    = "ami-0ac7b260cf76d8865"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.instance-sg.id]
  # key_name              = "your-key-pair-name"   # uncomment + set to SSH in

  tags = {
    Name = "terraform-hito"
  }
}

output "instance_public_ip" {
  value = aws_instance.myserver.public_ip
}


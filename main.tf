provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "cisco_img" {
  most_recent = true
  owners      = ["679593333241"] # Cisco Official Owner

  filter {
    name   = "name"
    values = ["cisco-C8K*"] # 'C8K' মানেই Catalyst 8000V, এটা অবশ্যই খুঁজে পাবে
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "cisco_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "Faruk-Cisco-VPC" }
}

resource "aws_internet_gateway" "cisco_igw" {
  vpc_id = aws_vpc.cisco_vpc.id
  tags   = { Name = "Faruk-Cisco-IGW" }
}

resource "aws_subnet" "cisco_subnet" {
  vpc_id                  = aws_vpc.cisco_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags                    = { Name = "Faruk-Cisco-Subnet" }
}

resource "aws_route_table" "cisco_rt" {
  vpc_id = aws_vpc.cisco_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cisco_igw.id
  }
}

resource "aws_route_table_association" "cisco_rta" {
  subnet_id      = aws_subnet.cisco_subnet.id
  route_table_id = aws_route_table.cisco_rt.id
}

resource "aws_security_group" "cisco_sg" {
  name        = "cisco-lab-sg-new"
  description = "Cisco Lab SG"
  vpc_id      = aws_vpc.cisco_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "cisco_router" {
  ami                    = data.aws_ami.cisco_img.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.cisco_subnet.id
  vpc_security_group_ids = [aws_security_group.cisco_sg.id]
  tags                   = { Name = "Faruk-Cisco-Router" }
}

output "router_ip" {
  value = aws_instance.cisco_router.public_ip
}
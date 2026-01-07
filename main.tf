provider "aws" {
  region = "us-east-1"
}

# ১. নতুন VPC তৈরি
resource "aws_vpc" "cisco_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Faruk-Cisco-VPC"
  }
}

# ২. ইন্টারনেট গেটওয়ে (ইন্টারনেট কানেকশনের জন্য)
resource "aws_internet_gateway" "cisco_igw" {
  vpc_id = aws_vpc.cisco_vpc.id

  tags = {
    Name = "Faruk-Cisco-IGW"
  }
}

# ৩. সাবনেট তৈরি
resource "aws_subnet" "cisco_subnet" {
  vpc_id                  = aws_vpc.cisco_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # যাতে রাউটার পাবলিক আইপি পায়

  tags = {
    Name = "Faruk-Cisco-Subnet"
  }
}

# ৪. রাউট টেবিল (ইন্টারনেটে ট্রাফিক পাঠানোর জন্য)
resource "aws_route_table" "cisco_rt" {
  vpc_id = aws_vpc.cisco_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cisco_igw.id
  }
}

# ৫. সাবনেটের সাথে রাউট টেবিল কানেক্ট করা
resource "aws_route_table_association" "cisco_rta" {
  subnet_id      = aws_subnet.cisco_subnet.id
  route_table_id = aws_route_table.cisco_rt.id
}

# ৬. সিকিউরিটি গ্রুপ (VPC ID সহ আপডেট করা)
resource "aws_security_group" "cisco_sg" {
  name        = "cisco-automation-sg"
  description = "Allow SSH for Faruk's Project"
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

# ৭. সিসকো রাউটার তৈরি
resource "aws_instance" "cisco_router" {
  ami           = "ami-0da63914a1e9ca467" 
  instance_type = "t3.medium"
  
  # আপনার সঠিক কী-পেয়ার এর নাম দিন, অথবা এটি আপাতত কমেন্ট করে রাখতে পারেন
  # key_name      = "your-key-name" 

  subnet_id              = aws_subnet.cisco_subnet.id
  vpc_security_group_ids = [aws_security_group.cisco_sg.id]

  tags = {
    Name = "Faruk-Cisco-Cloud-Router"
  }
}

output "router_ip" {
  value = aws_instance.cisco_router.public_ip
}
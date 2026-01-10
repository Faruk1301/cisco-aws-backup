provider "aws" {
  region = "us-east-1"
}

# ১. নেটওয়ার্ক তৈরি (VPC)
resource "aws_vpc" "cisco_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Faruk-Cisco-VPC"
  }
}

# ২. ইন্টারনেট গেটওয়ে
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
  map_public_ip_on_launch = true

  tags = {
    Name = "Faruk-Cisco-Subnet"
  }
}

# ৪. রাউট টেবিল সেটআপ
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

# ৫. সিকিউরিটি গ্রুপ (ডেসক্রিপশন এরর ফিক্স করা)
resource "aws_security_group" "cisco_sg" {
  name        = "cisco-automation-sg"
  description = "Allow SSH and HTTP for Cisco Lab"
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

# ৬. সিসকো রাউটার তৈরি (AMI আইডি আপডেট করা)
resource "aws_instance" "cisco_router" {
  ami           = "ami-0560938f825227d86" 
  instance_type = "t3.medium"
  
  # যদি আপনার AWS এ কোনো Key Pair থাকে তবে নাম দিন, নাহলে এটি এভাবেই রাখুন
  # key_name      = "your-key-name" 

  subnet_id              = aws_subnet.cisco_subnet.id
  vpc_security_group_ids = [aws_security_group.cisco_sg.id]

  tags = {
    Name = "Faruk-Cisco-Cloud-Router"
  }
}

# ৭. রাউটারের পাবলিক আইপি আউটপুট
output "router_ip" {
  value = aws_instance.cisco_router.public_ip
}
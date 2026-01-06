provider "aws" {
  region = "us-east-1"
}

# সিকিউরিটি গ্রুপ তৈরি
resource "aws_security_group" "cisco_sg" {
  name        = "cisco-automation-sg"
  description = "Allow SSH for Faruk's Project"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # এখানে আপনার পিসির পাবলিক আইপি দিলে বেশি নিরাপদ
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# সিসকো রাউটার তৈরি
resource "aws_instance" "cisco_router" {
  ami           = "ami-0da63914a1e9ca467" # Cisco Catalyst 8000V in us-east-1
  instance_type = "t3.medium"
  key_name      = "your-key-name" # আপনার AWS Key Pair এর সঠিক নাম এখানে দিন

  vpc_security_group_ids = [aws_security_group.cisco_sg.id]

  tags = {
    Name = "Faruk-Cisco-Cloud-Router"
  }
}

output "router_ip" {
  value = aws_instance.cisco_router.public_ip
}
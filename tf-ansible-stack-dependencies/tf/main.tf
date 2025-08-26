provider "aws" {
  region = "us-east-1"
}

# ✅ Define 2 instances with a map (hardcoded AMI)
locals {
  instances = {
    instance1 = {
      ami           = "ami-0360c520857e3138f" 
      instance_type = "t3.micro"
    }
    instance2 = {
      ami           = "ami-0360c520857e3138f" 
      instance_type = "t3.micro"
    }
  }
}

# ✅ Key Pair (use your existing public key file)
resource "aws_key_pair" "ssh_key" {
  key_name   = "ec2-key"
  public_key = file(var.public_key)
}

# ✅ Security Group for SSH + HTTP
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP traffic"

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
}

# ✅ Create EC2 instances with for_each
resource "aws_instance" "this" {
  for_each                    = local.instances
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]

  tags = {
    Name = each.key
  }
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.43"
    }
  }

  required_version = ">= 1.14.7"
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

resource "aws_security_group" "allow_ssh_and_http" {
  name        = var.sg_name
  description = "Allow ssh inbound traffic"
  vpc_id      = var.vpc_id

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
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-ssh-and-http"
    Enviroment = "test"
    Terraformed = true
  }
}

resource "aws_instance" "terraform-ansible-lab" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.allow_ssh_and_http.id]
  key_name                    = var.key_aws_instance
  user_data                   = <<-EOF
    #!/bin/bash 
    sudo apt update && sudo apt install git ansible -y
    git clone https://github.com/mathsmeireles/ansible-bootcamp-sre-elven.git
    cd /ansible-bootcamp-sre-elven
    sudo ansible-playbook wordpress.yml
    EOF
  monitoring                  = true
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name = "terraform-ansible-lab"
    Enviroment = "test"
    Terraformed = true
  }
}
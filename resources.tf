resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name        = var.vpc_name
    Enviroment  = var.enviroment
    Terraformed = true
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.pub_subnet_cidr_block

  tags = {
    Name        = var.pub_subnet_name
    Enviroment  = var.enviroment
    Terraformed = true
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = var.igw_name
    Enviroment  = var.enviroment
    Terraformed = true
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = var.rtb_pub_name
    Enviroment  = var.enviroment
    Terraformed = true
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_ssh_and_http" {
  name        = var.sg_name
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.this.id

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
    Name        = var.sg_name
    Enviroment  = var.enviroment
    Terraformed = true
  }
}

resource "aws_instance" "wordpress" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.allow_ssh_and_http.id]
  key_name                    = var.key_aws_instance
  user_data                   = <<-EOF
    #!/bin/bash 
    sudo apt update && sudo apt install git ansible -y
    git clone ${var.ansible_repo}
    cd /${local.folder_repo_name}
    sudo ansible-playbook wordpress.yml
    EOF
  monitoring                  = true
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true

  tags = {
    Name        = var.instance_name
    Enviroment  = var.enviroment
    Terraformed = true
  }
}
resource "aws_vpc" "lab-vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name        = var.vpc_name
    Enviroment  = var.enviroment
    Terraformed = true
  }
}

resource "aws_subnet" "pub_subnet" {
  vpc_id     = aws_vpc.lab-vpc.id
  cidr_block = var.pub_subnet_cidr_block

  tags = {
    Name        = var.pub_subnet_name
    Enviroment  = var.enviroment
    Terraformed = true
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab-vpc.id

  tags = {
    Name        = var.igw_name
    Enviroment  = var.enviroment
    Terraformed = true
  }
}

resource "aws_route_table" "rtb_pub_subnet" {
  vpc_id = aws_vpc.lab-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = var.rtb_pub_name
    Enviroment  = var.enviroment
    Terraformed = true
  }
}

resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.rtb_pub_subnet.id
}

resource "aws_security_group" "sg_allow_ssh_and_http" {
  name        = var.sg_name
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.lab-vpc.id

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

resource "aws_instance" "wordpress_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.sg_allow_ssh_and_http.id]
  key_name                    = var.key_aws_instance
  user_data                   = <<-EOF
    #!/bin/bash 
    sudo apt update && sudo apt install git ansible -y
    git clone ${var.ansible_repo}
    cd /${local.folder_repo_name}
    sudo ansible-playbook wordpress.yml
    EOF
  monitoring                  = true
  subnet_id                   = aws_subnet.pub_subnet.id
  associate_public_ip_address = true

  tags = {
    Name        = var.instance_name
    Enviroment  = var.enviroment
    Terraformed = true
  }
}
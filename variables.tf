variable "vpc_cidr_block" {}

variable "vpc_name" {}

variable "pub_subnet_cidr_block" {}

variable "pub_subnet_name" {}

variable "igw_name" {}

variable "rtb_pub_name" {}

variable "enviroment" {}

variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = "default"
}

variable "sg_name" {}

variable "instance_name" {}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_aws_instance" {}

variable "ansible_repo" {
  default = "https://github.com/mathsmeireles/ansible-bootcamp-sre-elven.git"
}
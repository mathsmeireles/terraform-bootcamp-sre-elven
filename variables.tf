variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = "default"
}

variable "sg_name" {}

variable "vpc_id" {}

variable "ami" {
  default = "ami-04505e74c0741db8d"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "subnet_id" {}

variable "key_aws_instance" {}
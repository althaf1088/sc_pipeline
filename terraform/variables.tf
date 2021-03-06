variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

variable "subnets_cidr" {
  type    = "list"
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnets_cidr" {
  type    = "list"
  default = ["10.20.3.0/24", "10.20.4.0/24"]
}

variable "azs" {
  type    = "list"
  default = ["us-east-1a", "us-east-1b"]
}

variable "webservers_ami" {
  default = "ami-0ff8a91507f77f867"
}

variable "instance_type" {
  default = "t2.nano"
}

variable "key_name" {
  default = "sc_deploy"
}

variable "public_key_path" {
  default = "/var/lib/jenkins/.ssh/sc_deploy.pub"
}

variable "asg_max" {
  default = 3
}

variable "asg_min" {
  default = 1
}

variable "asg_desired" {
  default = 3
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "subnet_cidrs" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "List of CIDR blocks for the subnets"
}

variable "prefix" {
  type = string
  default = "j09"
  description = "Prefix for resource names"
}

variable "region" {
  type = string
  default = "us-east-1"
  description = "AWS region to deploy resources"
}
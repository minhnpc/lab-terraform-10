terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0.0"
    }
  }
}
provider "aws" {
  region = var.region
}

locals {
  env      = terraform.workspace
  num      = terraform.workspace == "dev" ? "1" : "2" # dev = 1 , prod = 2 
  az       = terraform.workspace == "dev" ? "ap-southeast-1a" : "ap-southeast-1b"
  isPublic = terraform.workspace == "dev" ? "1" : "2" # dev = 1 , prod = 2
}


resource "aws_vpc" "vpc10" {
  cidr_block = "10.${local.num}.0.0/16"
  tags = {
    Name = "${local.env}-vpc"
  }
}

resource "aws_subnet" "subnet10" {
  vpc_id                  = aws_vpc.vpc10.id
  availability_zone       = local.az
  count                   = 2
  map_public_ip_on_launch = count.index + 1 == 1 ? false : true
  cidr_block              = "10.${local.num}.${count.index + 1 == 1 ? "1" : "2"}.0/24"


  tags = {
    key   = "environment"
    value = "${local.env}"
    Name  = "${local.env}-${count.index + 1 == 1 ? "private" : "public"}-subnet"
  }

}



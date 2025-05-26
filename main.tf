terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0.0"
    }
  }
  backend "s3" {
    bucket         = "npcminh-t10-bucket-2505"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "TerraformStateLock"
  }
}

provider "aws" {
  region = var.region
}

locals {
  env           = terraform.workspace
  num           = terraform.workspace == "dev" ? "1" : "2" # dev = 1 , prod = 2 
  az            = terraform.workspace == "dev" ? "ap-southeast-1a" : "ap-southeast-1b"
  isPublic      = terraform.workspace == "dev" ? "1" : "2" # dev = 1 , prod = 2
  ami           = terraform.workspace == "dev" ? var.instance_attr["dev"].ami : var.instance_attr["prod"].ami
  instance_type = terraform.workspace == "dev" ? var.instance_attr["dev"].type : var.instance_attr["prod"].type
  key_name      = terraform.workspace == "dev" ? var.instance_attr["dev"].key_name : var.instance_attr["prod"].key_name
}

module "vpc" {
  source           = "./modules/vpc"
  num              = local.num
  env              = local.env
  route_cidr_block = var.route_cidr_block
}

module "subnets" {
  source = "./modules/subnets"
  num    = local.num
  env    = local.env
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source                   = "./modules/alb"
  env                      = local.env
  security_group_public_id = module.security_groups.security_group_public_id
  subnet_id                = module.subnets.subnet_id
  vpc_id                   = module.vpc.vpc_id
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "ec2_launch_templates" {
  source                   = "./modules/ec2_launch_templates"
  instance_attr            = var.instance_attr[local.env]
  env                      = local.env
  security_group_public_id = module.security_groups.security_group_public_id
  user_data                = var.user_data[local.env]
}

module "autoscaling_group" {
  source             = "./modules/auto_scaling_groups"
  env                = local.env
  subnet_id          = module.subnets.subnet_id
  launch_template_id = module.ec2_launch_templates.launch_template_id
}

resource "aws_route_table_association" "rta10_1" {
  route_table_id = module.vpc.rt10_id
  subnet_id      = module.subnets.subnet_id[1]
}

resource "aws_route_table_association" "rta10_3" {
  route_table_id = module.vpc.rt10_id
  subnet_id      = module.subnets.subnet_id[3]
}

resource "aws_autoscaling_attachment" "lba10" {
  count                  = length(module.subnets.subnet_id)
  autoscaling_group_name = module.autoscaling_group.autoscaling_group_public_name
  lb_target_group_arn    = module.alb.lb_target_group[count.index].arn
}

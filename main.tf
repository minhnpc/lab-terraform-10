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

resource "aws_route_table_association" "rta10_1" {
  route_table_id = module.vpc.rt10_id
  subnet_id      = module.subnets.subnet_id[1]
}

resource "aws_route_table_association" "rta10_3" {
  route_table_id = module.vpc.rt10_id
  subnet_id      = module.subnets.subnet_id[3]
}


resource "aws_security_group" "sec10_public" {
  vpc_id = module.vpc.vpc_id
  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sec10_private" {
  vpc_id = module.vpc.vpc_id
  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.1.2.0/24", "10.2.2.0/24"]
  }
  ingress {
    description = "allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.1.2.0/24", "10.2.2.0/24"]
  }
  egress {
    description = "outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.1.2.0/24", "10.1.4.0/24"]
  }
}


resource "aws_lb" "alb10" {
  name               = "${local.env}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sec10_public.id]
  subnets            = [module.subnets.subnet_id[1], module.subnets.subnet_id[3]]
  tags = {
    Name = "${local.env}-lb"
  }

}

resource "aws_lb_listener" "lb_listener10_1" {
  load_balancer_arn = aws_lb.alb10.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.targetGr10[1].arn
        weight = 80
      }

      target_group {
        arn    = aws_lb_target_group.targetGr10[3].arn
        weight = 20
      }

      stickiness {
        enabled  = false
        duration = 1
      }
    }
  }
}



resource "aws_lb_target_group" "targetGr10" {
  vpc_id      = module.vpc.vpc_id
  count       = length(module.subnets.subnet_id)
  name_prefix = "Tgroup"
  protocol    = "HTTP"
  port        = 80
  target_type = "instance"
  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  tags = {
    Name = "${local.env}-${(count.index + 1) % 2 == 1 ? "private" : "public"}-targetGroup"
  }
}

resource "aws_autoscaling_group" "autoScalingGr_private" {
  name_prefix         = "ASG-private"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = [module.subnets.subnet_id[0], module.subnets.subnet_id[2]]
  launch_template {
    id      = aws_launch_template.launch_template10.id
    version = "$Latest"
  }
  tag {
    propagate_at_launch = true
    key                 = "Name"
    value               = "${local.env}-private-webServer"
  }
}

resource "aws_autoscaling_group" "autoScalingGr_public" {
  name_prefix         = "ASG-public"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = [module.subnets.subnet_id[1], module.subnets.subnet_id[3]]
  launch_template {
    id      = aws_launch_template.launch_template10.id
    version = "$Latest"
  }
  tag {
    propagate_at_launch = true
    key                 = "Name"
    value               = "${local.env}-public-webServer"
  }
}


resource "aws_launch_template" "launch_template10" {
  name_prefix            = "${local.env}-launch-"
  image_id               = local.ami
  instance_type          = local.instance_type
  key_name               = local.key_name
  vpc_security_group_ids = [aws_security_group.sec10_public.id]
}


resource "aws_autoscaling_attachment" "lba10" {
  count                  = length(module.subnets.subnet_id)
  autoscaling_group_name = aws_autoscaling_group.autoScalingGr_public.name
  lb_target_group_arn    = aws_lb_target_group.targetGr10[count.index].arn
}

resource "aws_autoscaling_group" "autoScalingGr_private" {
  name_prefix         = "ASG-private"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = [var.subnet_id[0], var.subnet_id[2]]
  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }
  tag {
    propagate_at_launch = true
    key                 = "Name"
    value               = "${var.env}-private-webServer"
  }
}

resource "aws_autoscaling_group" "autoScalingGr_public" {
  name_prefix         = "ASG-public"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = [var.subnet_id[1], var.subnet_id[3]]
  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }
  tag {
    propagate_at_launch = true
    key                 = "Name"
    value               = "${var.env}-public-webServer"
  }
}

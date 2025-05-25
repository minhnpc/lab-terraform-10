resource "aws_launch_template" "launch_template10" {
  name_prefix            = "${var.env}-launch-"
  image_id               = var.instance_attr.ami
  instance_type          = var.instance_attr.type
  key_name               = var.instance_attr.key_name
  vpc_security_group_ids = [var.security_group_public_id]
}

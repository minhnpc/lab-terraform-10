output "lb_target_group" {
  value = aws_lb_target_group.targetGr10
}

output "alb_dns_name" {
  value = aws_lb.alb10.dns_name
}

output "VPC" {
  value = module.vpc.vpc
}

output "subnets" {
  value = [for s in module.subnets.subnet_infos :
    "${s.tags.Name} : ${s.cidr_block}: ${s.id}"
  ]
}

output "dns_name" {
  value = module.alb.alb_dns_name
}

# output "instances" {
#   value = [for s in aws_autoscaling_group.autoScalingGr :
#     "Name: ${s.tags.Name} - public IP: ${s.public_ip} "
#   ]
# }

# output "autoscaling_group_name" {
#   value = [for s in aws_autoscaling_group.autoScalingGr :
#   "Name : ${s.name}"]
# }

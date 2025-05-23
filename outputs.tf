output "VPC" {
  value = "${aws_vpc.vpc10.tags.Name} : ${aws_vpc.vpc10.cidr_block}"
}

output "subnets" {
  value = [for s in aws_subnet.subnet10 :
    "${s.tags.Name} : ${s.cidr_block}"
  ]
}

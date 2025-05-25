output "vpc" {
  value = "${aws_vpc.vpc10.tags.Name} : ${aws_vpc.vpc10.cidr_block}"
}

output "vpc_id" {
  value = aws_vpc.vpc10.id
}

output "rt10_id" {
  value = aws_route_table.rt10.id
}

output "gtw_id" {
  value = aws_internet_gateway.igw10.id
}

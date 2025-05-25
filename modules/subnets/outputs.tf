output "subnet_id" {
  value = [for s in aws_subnet.subnet10 : s.id]
}

output "subnet_infos" {
  value = [for s in aws_subnet.subnet10 : s]
}

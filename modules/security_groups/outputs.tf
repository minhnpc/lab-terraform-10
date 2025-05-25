output "security_group_private_id" {
  value = aws_security_group.sec10_private.id
}

output "security_group_public_id" {
  value = aws_security_group.sec10_public.id
}

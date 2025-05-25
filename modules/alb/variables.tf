variable "env" {
  type = string
}

variable "security_group_public_id" {
  type = string
}

variable "subnet_id" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "instance_attr" {
  type = object({
    ami      = string
    type     = string
    key_name = string
  })
}

variable "env" {
  type = string
}

variable "security_group_public_id" {
  type = string
}

variable "region" {
  type = string
}

variable "route_cidr_block" {
  type = string
}

variable "instance_attr" {
  type = map(object({
    ami      = string
    type     = string
    key_name = string
  }))
}

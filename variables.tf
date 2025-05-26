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

variable "user_data" {
  type = map(list(string))
}

# variable "ssh_infos" {
#   type = map(object({
#     ssh_key_dir = string
#     user        = string
#     type        = string
#     host        = string
#   }))
# }

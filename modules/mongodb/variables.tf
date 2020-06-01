variable region {
  type = string
}

# TODO: introduce....
# variable project_name {
#   type = string
# }

variable db_port {
  type    = number
  default = 27017
}

variable db_root_username {
  type    = string
  default = "root"
}

variable db_root_password {
  type    = string
  default = "root"
}

variable tags {
  type    = map
  default = {}
}

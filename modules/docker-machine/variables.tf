variable region {
  type = string
}

variable project_name {
  type = string
}

variable ssh_private_key {
  type = string
}

variable ssh_public_key {
  type = string
}

variable instance_type {
  type    = string
  default = "t1.micro"
}

variable tags {
  type    = map
  default = {}
}

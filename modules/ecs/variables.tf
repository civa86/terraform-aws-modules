variable region {
  type = string
}

variable project_name {
  type = string
}

variable cpu {
  type    = string
  default = "256"
}

variable memory {
  type    = string
  default = "512"
}

variable replicas {
  type = number
}

variable auto_scaling_max_replicas {
  type = number
}

variable auto_scaling_max_cpu_util {
  type = number
}

variable tags {
  type    = map
  default = {}
}

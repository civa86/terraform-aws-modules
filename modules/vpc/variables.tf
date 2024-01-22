variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "s3_vpc_gateway_endpoint" {
  type    = bool
  default = false
}

variable "dynamodb_vpc_gateway_endpoint" {
  type    = bool
  default = false
}

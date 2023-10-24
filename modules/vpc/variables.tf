variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}
# availability_zones       = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
variable "tags" {
  type    = map(any)
  default = {}
}

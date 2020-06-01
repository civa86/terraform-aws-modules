terraform {
  required_version = ">= 0.12"
}

locals {
  region = "eu-west-1"
}

provider "aws" {
  region = local.region
}

module "mongodb" {
  source           = "../../modules/mongodb"
  region           = local.region
  db_port          = 27017
  db_root_username = "root"
  db_root_password = "root"
}

output "db_url" {
  value       = module.mongodb.db_url
  description = "MongoDB Connection URL"
}



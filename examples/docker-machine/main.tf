terraform {
  required_version = ">= 0.12"
}

locals {
  region = "eu-west-1"
}

provider "aws" {
  region = local.region
}

module "docker_machine" {
  source          = "../../modules/docker-machine"
  region          = local.region
  project_name    = "docker-master"
  instance_type   = "t1.micro"
  ssh_private_key = "${path.cwd}/key.pem"
  ssh_public_key  = "${path.cwd}/key.pem.pub"
}

output "docker_ip" {
  value       = module.docker_machine.docker_ip
  description = "Docker Machine public IP"
}



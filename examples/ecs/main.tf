terraform {
  required_version = ">= 0.12"
}

locals {
  region = "eu-west-1"
}

provider "aws" {
  region = local.region
}

module "ecs" {
  source                    = "../../modules/ecs"
  region                    = local.region
  project_name              = "microsvc"
  cpu                       = "256"
  memory                    = "512"
  replicas                  = 1
  auto_scaling_max_replicas = 4
  auto_scaling_max_cpu_util = 60
}

output "alb_url" {
  value       = module.ecs.alb_url
  description = "ALB endpoint URL"
}




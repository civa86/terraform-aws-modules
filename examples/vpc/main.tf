terraform {
  required_version = ">= 1.0.0"

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67"
    }
  }
}

locals {
  project = "test"
  env     = terraform.workspace
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      project = local.project
      env     = local.env
    }
  }
}

module "vpc" {
  source                        = "../../modules/vpc"
  project                       = local.project
  env                           = local.env
  availability_zones            = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  s3_vpc_gateway_endpoint       = true
  dynamodb_vpc_gateway_endpoint = true
}


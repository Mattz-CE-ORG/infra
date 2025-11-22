terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "Ars-Org"

    workspaces {
      name = "infra"
      # This workspace is connected to GitHub repo: https://github.com/Mattz-CE-ORG/infra
      # The repository is the source of truth for all infrastructure changes
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Credentials from environment variables
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
  # or from AWS credentials file/instance profile
}

# Module for the first Lightsail instance
module "ls_node" {
  source = "./lightsail"

  instance_name = "ls-node-01"
  tags = {
    Environment = "production"
    Project     = "lightsail-servers"
  }
}

output "node_ip" {
  value = module.ls_node.static_ip
}

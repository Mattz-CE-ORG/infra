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

  # Credentials from environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
  # OR passed via variables below if set in Terraform Cloud as 'Terraform Variables'
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
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
}

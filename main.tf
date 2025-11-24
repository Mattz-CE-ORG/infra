terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
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

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Generate a random password for WireGuard UI
resource "random_password" "wg_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Module for the first Lightsail instance
module "ls_node" {
  source = "./lightsail"

  instance_name = "ls-node-01"
  wg_password   = random_password.wg_password.result
  tags = {
    Environment = "production"
    Project     = "lightsail-servers"
  }
}

# Cloudflare module - manages all DNS records
module "cloudflare_resources" {
  source = "./cloudflare"

  zone_id = var.cloudflare_zone_id

  # Dynamic record for the Lightsail instance
  create_dynamic_record = true
  name    = "ls-node-01"
  value   = module.ls_node.static_ip
  type    = "A"
  proxied = false
}

output "node_ip" {
  value = module.ls_node.static_ip
}

output "secret_output" {
  description = "Secret configuration details"
  value = {
    wg_web_ui  = module.ls_node.wg_web_ui
    wg_password = random_password.wg_password.result
  }
  sensitive = true
}

output "node_hostname" {
  value = module.cloudflare_resources.record_hostname
}

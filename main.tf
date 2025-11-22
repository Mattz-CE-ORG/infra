terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: Configure backend for state management
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "ars-org/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region

  # Credentials from environment variables
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
  # or from AWS credentials file/instance profile
}

# Add your resources here when ready


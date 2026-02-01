terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration will be enabled after S3 bucket creation
  # backend "s3" {
  #   bucket         = "lucas-terraform-state-hardened"
  #   key            = "global/s3/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  # Global tagging strategy
  default_tags {
    tags = {
      Project     = "Cloud-Native-Hardened-IaC"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Lucas"
    }
  }
}

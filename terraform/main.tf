provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Cloud-Native-Hardened-IaC"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Lucas"
    }
  }
}

data "aws_caller_identity" "current" {}

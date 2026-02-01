# terraform {
#   backend "s3" {
#     bucket         = "lucas-terraform-state-hardened"
#     key            = "global/s3/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-locks"
#     encrypt        = true
#   }
# }

terraform {
  backend "s3" {
    bucket         = "024258572091-terraform-tfstate"
    key            = "domain1/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-tfstate-lock"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
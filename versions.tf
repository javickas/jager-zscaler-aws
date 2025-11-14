# versions.tf
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Use a recent, stable version
    }
  }
}

# Configure the AWS Provider
###SSO Credentials need to be updated####

provider "aws" {
  region = var.region
  shared_config_files = ["/Users/*****/.aws/config"]
  shared_credentials_files = ["/Users/******/.aws/credentials"]
  profile = "********"
    
}
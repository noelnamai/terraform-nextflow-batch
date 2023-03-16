terraform {
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
    }
  }

  required_version = ">= 0.14.9"
}

# configure the aws provider configuration
provider "aws" {
  region = "us-east-1"
}

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

provider "vault" {
  skip_tls_verify = true
}

data "vault_generic_secret" "tf_secret_vault_development" {
  path = "development/aws"
}

# configure the aws provider configuration
provider "aws" {
  region     = local.region
  access_key = data.vault_generic_secret.tf_secret_vault_development.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.tf_secret_vault_development.data["AWS_SECRET_ACCESS_KEY"]
}

terraform {
  # cloud {
  #   organization = "JUANROLDAN-training"

  #   workspaces {
  #     name = "terraform-with-api-gateway-and-lambda-function"
  #   }
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.21.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.3.6"
}

provider "aws" {
  region = "us-east-1"
}

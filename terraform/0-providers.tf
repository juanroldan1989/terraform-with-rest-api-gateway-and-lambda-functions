terraform {
  cloud {
    organization = "JUANROLDAN-training"

    workspaces {
      name = "terraform-with-rest-api-gateway-and-lambda-functions"
    }
  }

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

locals {
  terraform-base-tag = "terraform-rest-api-with-lambda"
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      owner       = "Juan Roldan"
      project     = "REST API with Lambda Functions"
      cost-center = "API Billing"
      Name        = "Managed by Terraform"
      // This regex results in the terraform git
      // repo name and any sub-directories.
      // For this repo, terraform-base-path is
      // terraform-rest-api-with-lambda/default-tags
      // This tag helps AWS UI users discover what
      // Terraform git repo and directory to modify
      terraform-base-path = replace(path.cwd,
      "/^.*?(${local.terraform-base-tag}\\/)/", "$1")
    }
  }
}

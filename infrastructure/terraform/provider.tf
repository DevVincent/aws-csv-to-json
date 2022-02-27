terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.REGION
}

provider "aws" {
  alias   = "north_virginia"
  region  = "us-east-1"
}
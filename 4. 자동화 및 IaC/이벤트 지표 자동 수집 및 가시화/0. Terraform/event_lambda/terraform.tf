terraform {
  backend "s3" {
    bucket  = "backend-bucket"
    key     = "terraform.tfstate"
    region  = "ap-northeast-2"
    profile = ""
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region  = var.region
  profile = ""
}
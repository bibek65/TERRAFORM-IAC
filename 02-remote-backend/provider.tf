# provider.tf — Remote backend configuration

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Native S3 locking requires Terraform >= 1.10 and S3 Object Lock enabled on the bucket
  backend "s3" {
    bucket       = "my-terraform-bucket-12345-use1"
    key          = "beginners-guide/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}

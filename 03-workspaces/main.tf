# main.tf — Using terraform.workspace to create environment-specific resources

locals {
  # terraform.workspace returns the current workspace name
  # e.g., "dev", "staging", "prod"
  environment = terraform.workspace

  bucket_name = "${var.project_name}-${local.environment}-data-12345"

  common_tags = {
    Environment = local.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket" "app_data" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# main.tf — Create multiple S3 buckets using the reusable module

module "app_data_bucket" {
  source = "./modules/s3-bucket"

  bucket_name       = "${var.project_name}-app-data-${var.environment}"
  environment       = var.environment
  enable_versioning = true
}

module "logs_bucket" {
  source = "./modules/s3-bucket"

  bucket_name       = "${var.project_name}-logs-${var.environment}"
  environment       = var.environment
  enable_versioning = false
}

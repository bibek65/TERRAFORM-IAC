# main.tf — Create multiple S3 buckets using the reusable module

module "app_data_bucket" {
  source = "./modules/s3-bucket"

  bucket_name       = "${var.project_name}-app-data-${var.environment}"
  environment       = var.environment
  enable_versioning = true
}

# Use count to conditionally create one extra bucket.
module "logs_bucket" {
  count  = var.create_logs_bucket ? 2 : 0
  source = "./modules/s3-bucket"

  bucket_name       = "${var.project_name}-logs-${var.environment}-${count.index + 1}"
  environment       = var.environment
  enable_versioning = false
}

# Use for_each to create one bucket per team.
module "team_buckets" {
  for_each = var.team_buckets
  source   = "./modules/s3-bucket"

  bucket_name       = "${var.project_name}-${each.key}-${var.environment}"
  environment       = var.environment
  enable_versioning = each.value.enable_versioning
}

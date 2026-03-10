# outputs.tf — Root outputs (referencing module outputs)

output "app_data_bucket_name" {
  description = "Name of the app data S3 bucket"
  value       = module.app_data_bucket.bucket_id
}

output "app_data_bucket_arn" {
  description = "ARN of the app data S3 bucket"
  value       = module.app_data_bucket.bucket_arn
}

output "logs_bucket_name" {
  description = "Name of the logs S3 bucket"
  value       = module.logs_bucket.bucket_id
}

output "logs_bucket_arn" {
  description = "ARN of the logs S3 bucket"
  value       = module.logs_bucket.bucket_arn
}

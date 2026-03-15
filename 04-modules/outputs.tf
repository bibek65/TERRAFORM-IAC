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
  description = "Name of the logs S3 bucket (null if not created)"
  value       = try(module.logs_bucket[0].bucket_id, null)
}

output "team_bucket_names" {
  description = "Bucket names created with for_each"
  value       = { for team, bucket in module.team_buckets : team => bucket.bucket_id }
}

output "team_bucket_arns" {
  description = "Bucket ARNs created with for_each"
  value       = { for team, bucket in module.team_buckets : team => bucket.bucket_arn }
}


# outputs.tf — Display useful info after apply

output "workspace" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}

output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.app_data.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.app_data.arn
}

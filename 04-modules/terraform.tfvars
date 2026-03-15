# terraform.tfvars — Set values for variables

aws_region   = "us-east-1"
project_name = "myapp"
environment  = "dev"

create_logs_bucket = true

team_buckets = {
  analytics = {
    enable_versioning = true
  }
  engineering = {
    enable_versioning = false
  }
}

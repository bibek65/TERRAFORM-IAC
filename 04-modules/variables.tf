# variables.tf — Root variables

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "create_logs_bucket" {
  description = "Whether to create a logs bucket (used with count)"
  type        = bool
  default     = true
}

variable "team_buckets" {
  description = "Map of team buckets to create (used with for_each)"
  type = map(object({
    enable_versioning = bool
  }))
  default = {
    analytics = {
      enable_versioning = true
    }
    engineering = {
      enable_versioning = false
    }
  }
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  ephemeral   = true
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
  ephemeral   = true
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  ephemeral   = true
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
  ephemeral   = true
}

variable "db_security_group_id" {
  description = "Database security group ID"
  type        = string
  ephemeral   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  ephemeral   = true
}

variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "enable_backup" {
  description = "Enable RDS backup"
  type        = bool
  ephemeral   = true
}

variable "backup_retention_days" {
  description = "RDS backup retention days"
  type        = number
  ephemeral   = true
}

variable "monitoring_enabled" {
  description = "Enable enhanced monitoring"
  type        = bool
  ephemeral   = true
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  ephemeral   = true
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  ephemeral   = true
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
  ephemeral   = true
}
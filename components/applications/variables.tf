# 환경 설정
variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

# 네트워크 설정 (기본 스택에서 전달)
variable "vpc_id" {
  description = "VPC ID from core stack"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs from core stack"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs from core stack"
  type        = list(string)
}

variable "web_security_group_id" {
  description = "Web security group ID from core stack"
  type        = string
}

variable "db_security_group_id" {
  description = "Database security group ID from core stack"
  type        = string
}

variable "ec2_instance_profile_arn" {
  description = "EC2 instance profile ARN from core stack"
  type        = string
}

# 애플리케이션 설정
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "enable_backup" {
  description = "Enable RDS backup"
  type        = bool
}

# YAML에서 읽은 설정들
variable "backup_retention_days" {
  description = "RDS backup retention days"
  type        = number
}

variable "monitoring_enabled" {
  description = "Enable enhanced monitoring"
  type        = bool
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
}

# 데이터베이스 인증은 AWS Secrets Manager에서 자동 관리됨
# db_username = "admin" (하드코딩)
# db_password = AWS가 자동 생성 및 관리

# 공통 태그
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
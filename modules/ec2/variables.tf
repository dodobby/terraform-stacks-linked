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

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
  ephemeral   = true
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EC2 instances"
  type        = list(string)
  ephemeral   = true
}

variable "web_security_group_id" {
  description = "Web security group ID"
  type        = string
  ephemeral   = true
}

variable "ec2_instance_profile_arn" {
  description = "EC2 instance profile ARN"
  type        = string
  ephemeral   = true
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  ephemeral   = true
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
  ephemeral   = true
}
# EC2 출력
output "web_server_ids" {
  description = "Web server instance IDs"
  value       = module.ec2.web_server_ids
}

output "web_server_private_ips" {
  description = "Web server private IP addresses"
  value       = module.ec2.web_server_private_ips
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = module.ec2.load_balancer_dns
}

output "load_balancer_arn" {
  description = "Load balancer ARN"
  value       = module.ec2.load_balancer_arn
}

# RDS 출력
output "database_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.database_endpoint
  sensitive   = true
}

output "database_port" {
  description = "RDS database port"
  value       = module.rds.database_port
}

output "database_name" {
  description = "RDS database name"
  value       = module.rds.database_name
}

# S3 출력
output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.s3_bucket_arn
}

# Secrets Manager 출력 (AWS 기본 KMS 키 사용)
output "master_user_secret_arn" {
  description = "ARN of the master user secret in AWS Secrets Manager"
  value       = module.rds.master_user_secret_arn
  sensitive   = true
}

output "master_user_secret_status" {
  description = "Status of the master user secret in AWS Secrets Manager"
  value       = module.rds.master_user_secret_status
}
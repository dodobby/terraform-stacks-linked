output "database_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "database_port" {
  description = "RDS database port"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "RDS database name"
  value       = aws_db_instance.main.db_name
}

output "database_arn" {
  description = "RDS database ARN"
  value       = aws_db_instance.main.arn
}

output "database_id" {
  description = "RDS database ID"
  value       = aws_db_instance.main.id
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "db_parameter_group_name" {
  description = "DB parameter group name"
  value       = aws_db_parameter_group.main.name
}

# Secrets Manager outputs (AWS 기본 KMS 키 사용)
output "master_user_secret_arn" {
  description = "ARN of the master user secret in AWS Secrets Manager"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
  sensitive   = true
}

output "master_user_secret_status" {
  description = "Status of the master user secret in AWS Secrets Manager"
  value       = aws_db_instance.main.master_user_secret[0].secret_status
}
# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-app-db-subnet-group-${var.environment}"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-db-subnet-group-${var.environment}"
    Type = "db-subnet-group"
  })
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  family = "mysql8.0"
  name   = "${var.name_prefix}-app-db-params-${var.environment}"

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

  parameter {
    name  = "max_connections"
    value = "200"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-db-params-${var.environment}"
    Type = "db-parameter-group"
  })
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.name_prefix}-app-db-${var.environment}"

  # Engine settings
  engine         = "mysql"
  engine_version = "8.0.35"
  instance_class = var.db_instance_class

  # Database settings
  db_name  = "appdb"
  username = var.db_username
  password = var.db_password
  port     = 3306

  # Storage settings
  allocated_storage     = var.environment == "prd" ? 100 : 20
  max_allocated_storage = var.environment == "prd" ? 1000 : 100
  storage_type          = "gp3"
  storage_encrypted     = true

  # Network settings
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false

  # Backup settings
  backup_retention_period = var.enable_backup ? var.backup_retention_days : 0
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot  = true
  delete_automated_backups = true

  # High Availability
  multi_az = var.multi_az

  # Monitoring
  monitoring_interval = var.monitoring_enabled ? 60 : 0
  monitoring_role_arn = var.monitoring_enabled ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.name_prefix}-core-role-rds-monitoring-${var.environment}" : null

  # Performance Insights
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? 7 : null

  # Parameter and option groups
  parameter_group_name = aws_db_parameter_group.main.name

  # Deletion protection
  deletion_protection = var.environment == "prd" ? true : false
  skip_final_snapshot = var.environment == "dev" ? true : false
  final_snapshot_identifier = var.environment != "dev" ? "${var.name_prefix}-app-db-final-snapshot-${var.environment}-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-db-${var.environment}"
    Type = "database"
  })
}

# Current AWS account ID
data "aws_caller_identity" "current" {}
# EC2 모듈
module "ec2" {
  source = "../../modules/ec2"

  name_prefix               = var.name_prefix
  environment              = var.environment
  vpc_id                   = var.vpc_id
  public_subnet_ids        = var.public_subnet_ids
  private_subnet_ids       = var.private_subnet_ids
  web_security_group_id    = var.web_security_group_id
  ec2_instance_profile_arn = var.ec2_instance_profile_arn
  instance_type            = var.instance_type
  tags                     = var.common_tags
}

# RDS 모듈
module "rds" {
  source = "../../modules/rds"

  name_prefix                  = var.name_prefix
  environment                  = var.environment
  vpc_id                       = var.vpc_id
  private_subnet_ids           = var.private_subnet_ids
  db_security_group_id         = var.db_security_group_id
  db_instance_class            = var.db_instance_class
  db_username                  = var.db_username
  db_password                  = var.db_password
  enable_backup                = var.enable_backup
  backup_retention_days        = var.backup_retention_days
  monitoring_enabled           = var.monitoring_enabled
  multi_az                     = var.multi_az
  performance_insights_enabled = var.performance_insights_enabled
  tags                         = var.common_tags
}

# S3 모듈
module "s3" {
  source = "../../modules/s3"

  name_prefix = var.name_prefix
  environment = var.environment
  tags        = var.common_tags
}
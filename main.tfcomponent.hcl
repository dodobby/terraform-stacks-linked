# =============================================================================
# 연결된 스택 컴포넌트 정의 (Application Services Stack)
# =============================================================================

# -----------------------------------------------------------------------------
# Provider 요구사항
# -----------------------------------------------------------------------------
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.70"
  }
  random = {
    source  = "hashicorp/random"
    version = "~> 3.6"
  }
}

# -----------------------------------------------------------------------------
# Provider 설정
# -----------------------------------------------------------------------------
provider "aws" "default" {
  config {
    access_key = var.aws_access_key_id
    secret_key = var.aws_secret_access_key
    region     = var.aws_region
    default_tags {
      tags = {
        Environment = var.environment
        Project     = var.project_name
        Owner       = var.owner
        CreatedBy   = var.createdBy
        CostCenter  = var.cost_center
        ManagedBy   = var.managed_by
        Stack       = "application-services"
      }
    }
  }
}

provider "random" "default" {
}

# -----------------------------------------------------------------------------
# 입력 변수 정의 - 애플리케이션 설정
# -----------------------------------------------------------------------------
variable "environment" {
  type        = string
  description = "Environment name (dev, stg, prd)"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "enable_backup" {
  type        = bool
  description = "Enable RDS backup"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "hjdo"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-2"
}

# -----------------------------------------------------------------------------
# AWS 자격증명 변수 (ephemeral 사용)
# -----------------------------------------------------------------------------
variable "aws_access_key_id" {
  type        = string
  description = "AWS access key ID"
  sensitive   = true
  ephemeral   = true
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key"
  sensitive   = true
  ephemeral   = true
}

# -----------------------------------------------------------------------------
# 입력 변수 정의 - 데이터베이스 인증
# -----------------------------------------------------------------------------
variable "db_username" {
  type        = string
  description = "Database master username"
  sensitive   = true
  ephemeral   = true
}

variable "db_password" {
  type        = string
  description = "Database master password"
  sensitive   = true
  ephemeral   = true
}

# -----------------------------------------------------------------------------
# 입력 변수 정의 - 공통 설정
# -----------------------------------------------------------------------------
variable "project_name" {
  type        = string
  description = "Project name"
}

variable "owner" {
  type        = string
  description = "Owner of the resources"
}

variable "createdBy" {
  type        = string
  description = "Creator of the resources"
}

variable "cost_center" {
  type        = string
  description = "Cost center"
}

variable "managed_by" {
  type        = string
  description = "Managed by"
}

# -----------------------------------------------------------------------------
# 민감한 정보 변수 (ephemeral 사용)
# -----------------------------------------------------------------------------
variable "temp_access_token" {
  type        = string
  description = "Temporary access token for deployment"
  sensitive   = true
  ephemeral   = true
  default     = ""
}

variable "deployment_key" {
  type        = string
  description = "Temporary deployment key"
  sensitive   = true
  ephemeral   = true
  default     = ""
}

# -----------------------------------------------------------------------------
# 입력 변수 정의 - 기본 스택에서 전달받을 값들
# -----------------------------------------------------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC ID from core stack"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs from core stack"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs from core stack"
}

variable "web_security_group_id" {
  type        = string
  description = "Web security group ID from core stack"
}

variable "db_security_group_id" {
  type        = string
  description = "Database security group ID from core stack"
}

variable "ec2_instance_profile_arn" {
  type        = string
  description = "EC2 instance profile ARN from core stack"
}

# -----------------------------------------------------------------------------
# 로컬 값 및 설정
# -----------------------------------------------------------------------------
locals {
  # YAML 파일에서 애플리케이션 설정 읽기 시도
  app_config = try(yamldecode(file("config/application-config.yaml")), {
    dev = { 
      backup_retention_days = 7,
      monitoring_enabled = false,
      log_level = "DEBUG",
      multi_az = false,
      performance_insights_enabled = false
    }
    stg = { 
      backup_retention_days = 14,
      monitoring_enabled = true,
      log_level = "INFO",
      multi_az = true,
      performance_insights_enabled = true
    }
    prd = { 
      backup_retention_days = 30,
      monitoring_enabled = true,
      log_level = "WARN",
      multi_az = true,
      performance_insights_enabled = true
    }
  })
  
  # 환경별 설정 추출
  current_config = try(local.app_config[var.environment], {
    backup_retention_days = 7
    monitoring_enabled = false
    log_level = "INFO"
    multi_az = false
    performance_insights_enabled = false
  })
  
  # 테스트 결과 확인용
  yaml_load_success = can(yamldecode(file("config/application-config.yaml")))
  locals_block_success = true
  
  # 실제 사용할 값들 (YAML 우선, 실패 시 기본값 사용)
  final_backup_retention_days = try(local.current_config.backup_retention_days, 7)
  final_monitoring_enabled = try(local.current_config.monitoring_enabled, false)
  final_log_level = try(local.current_config.log_level, "INFO")
  final_multi_az = try(local.current_config.multi_az, false)
  final_performance_insights_enabled = try(local.current_config.performance_insights_enabled, false)
  
  # 민감한 정보만 ephemeral 처리
  final_db_username = var.db_username
  final_db_password = var.db_password
  
  # 임시 민감한 값들 (실제 사용 시에만 활성화)
  final_temp_access_token = var.temp_access_token != "" ? var.temp_access_token : null
  final_deployment_key = var.deployment_key != "" ? var.deployment_key : null
  
  # 공통 태그
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = var.createdBy
    CostCenter  = var.cost_center
    ManagedBy   = var.managed_by
    Stack       = "application-services"
  }
}

# -----------------------------------------------------------------------------
# 컴포넌트 정의
# -----------------------------------------------------------------------------
component "applications" {
  source = "./components/applications"
  
  providers = {
    aws    = provider.aws.default
    random = provider.random.default
  }
  
  inputs = {
    # 환경 설정
    environment               = var.environment
    name_prefix              = var.name_prefix
    aws_region               = var.aws_region
    
    # 네트워크 설정 (기본 스택에서 전달)
    vpc_id                   = var.vpc_id
    public_subnet_ids        = var.public_subnet_ids
    private_subnet_ids       = var.private_subnet_ids
    web_security_group_id    = var.web_security_group_id
    db_security_group_id     = var.db_security_group_id
    ec2_instance_profile_arn = var.ec2_instance_profile_arn
    
    # 애플리케이션 설정
    instance_type            = var.instance_type
    db_instance_class        = var.db_instance_class
    enable_backup            = var.enable_backup
    
    # YAML에서 읽은 설정들
    backup_retention_days    = local.final_backup_retention_days
    monitoring_enabled       = local.final_monitoring_enabled
    multi_az                 = local.final_multi_az
    performance_insights_enabled = local.final_performance_insights_enabled
    
    # 데이터베이스 인증
    db_username              = local.final_db_username
    db_password              = local.final_db_password
    
    # 공통 태그
    common_tags              = local.common_tags
  }
}

# -----------------------------------------------------------------------------
# 출력 값 정의 - 애플리케이션 리소스
# -----------------------------------------------------------------------------
output "web_server_ids" {
  description = "Web server instance IDs"
  type        = list(string)
  value       = component.applications.web_server_ids
}

output "web_server_private_ips" {
  description = "Web server private IP addresses"
  type        = list(string)
  value       = component.applications.web_server_private_ips
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  type        = string
  value       = component.applications.load_balancer_dns
}

output "load_balancer_arn" {
  description = "Load balancer ARN"
  type        = string
  value       = component.applications.load_balancer_arn
}

# -----------------------------------------------------------------------------
# 출력 값 정의 - 데이터베이스
# -----------------------------------------------------------------------------
output "database_endpoint" {
  description = "RDS database endpoint"
  type        = string
  value       = component.applications.database_endpoint
  sensitive   = true
}

output "database_port" {
  description = "RDS database port"
  type        = number
  value       = component.applications.database_port
}

output "database_name" {
  description = "RDS database name"
  type        = string
  value       = component.applications.database_name
}

# -----------------------------------------------------------------------------
# 출력 값 정의 - 스토리지
# -----------------------------------------------------------------------------
output "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
  value       = component.applications.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  type        = string
  value       = component.applications.s3_bucket_arn
}

# -----------------------------------------------------------------------------
# 테스트 결과 출력
# -----------------------------------------------------------------------------
output "test_results" {
  description = "테스트 결과: locals 블록과 yamldecode 함수 지원 여부"
  type = object({
    locals_block_supported = bool
    yaml_file_loaded = bool
    backup_retention_days = number
    monitoring_enabled = bool
    log_level = string
    multi_az = bool
    performance_insights_enabled = bool
  })
  value = {
    locals_block_supported = local.locals_block_success
    yaml_file_loaded = local.yaml_load_success
    backup_retention_days = local.final_backup_retention_days
    monitoring_enabled = local.final_monitoring_enabled
    log_level = local.final_log_level
    multi_az = local.final_multi_az
    performance_insights_enabled = local.final_performance_insights_enabled
  }
}
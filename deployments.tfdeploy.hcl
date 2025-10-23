# =============================================================================
# 연결된 스택 배포 정의 (Application Services Stack Deployments)
# =============================================================================

# -----------------------------------------------------------------------------
# Variable Sets 참조 - 민감한 정보만 Variable Sets 사용
# -----------------------------------------------------------------------------
store "varset" "aws_credentials" {
  id       = "varset-VqTt9ubP3LPSFKeS"
  category = "env"
}

store "varset" "database_config" {
  id       = "varset-XqfL9jtRm2c16bMQ"
  category = "env"
}

# -----------------------------------------------------------------------------
# 기본 스택 출력 참조 - upstream_input 블록 (공식 문법)
# -----------------------------------------------------------------------------
upstream_input "core_infrastructure" {
  type   = "stack"
  source = "app.terraform.io/rum-org-korean-air/Stacks_GA/terraform-stacks-core"
}

# -----------------------------------------------------------------------------
# 자동 승인 정책 정의
# -----------------------------------------------------------------------------
deployment_auto_approve "dev_auto_approve" {
  check {
    condition = context.plan != null && context.plan.deployment != null && context.plan.deployment == deployment.dev
    reason    = "Automatically applying dev deployment for application services."
  }
}

deployment_auto_approve "small_app_changes" {
  check {
    condition = context.plan != null && context.plan.changes != null && context.plan.changes.total <= 5
    reason    = "Auto-approve small application changes."
  }
}

# -----------------------------------------------------------------------------
# 배포 그룹 정의 - 기본 스택 완료 후 배포
# -----------------------------------------------------------------------------
deployment_group "app_development" {
  auto_approve_checks = [
    deployment_auto_approve.dev_auto_approve,
    deployment_auto_approve.small_app_changes
  ]
}

deployment_group "app_staging" {
  auto_approve_checks = []  # 수동 승인
}

deployment_group "app_production" {
  auto_approve_checks = []  # 수동 승인
}

# -----------------------------------------------------------------------------
# 환경별 배포 정의
# -----------------------------------------------------------------------------

# 개발 환경 배포
deployment "dev" {
  inputs = {
    # 환경 구분
    environment   = "dev"
    enable_backup = false
    
    # 기본 스택에서 전달받는 네트워크 리소스 (upstream 사용)
    vpc_id                    = upstream.core_infrastructure.vpc_outputs.vpc_id
    public_subnet_ids         = upstream.core_infrastructure.vpc_outputs.public_subnet_ids
    private_subnet_ids        = upstream.core_infrastructure.vpc_outputs.private_subnet_ids
    web_security_group_id     = upstream.core_infrastructure.vpc_outputs.web_security_group_id
    db_security_group_id      = upstream.core_infrastructure.vpc_outputs.db_security_group_id
    ec2_instance_profile_arn  = upstream.core_infrastructure.vpc_outputs.ec2_instance_profile_arn
    
    # 애플리케이션 설정 (하드코딩된 값 - ephemeral 아님)
    instance_type     = "t3.micro"
    db_instance_class = "db.t3.micro"
    
    # AWS 자격증명 (Variable Sets에서 가져오기)
    aws_access_key_id     = store.varset.aws_credentials.AWS_ACCESS_KEY_ID
    aws_secret_access_key = store.varset.aws_credentials.AWS_SECRET_ACCESS_KEY
    
    # 공통 설정 (하드코딩된 값 - ephemeral 아님)
    aws_region    = "ap-northeast-2"
    project_name  = "terraform-stacks-demo"
    owner         = "devops-team"
    createdBy     = "hj.do"
    cost_center   = "engineering"
    managed_by    = "terraform-stacks"
    name_prefix   = "hjdo"
    
    # 민감한 정보 (Variable Sets에서 관리 - ephemeral)
    db_username  = store.varset.database_config.db_username
    db_password  = store.varset.database_config.db_password
    
    # 임시 민감한 값들 (필요 시에만 사용)
    temp_access_token = ""  # 기본값: 빈 문자열
    deployment_key    = ""  # 기본값: 빈 문자열
  }
  
  deployment_group = deployment_group.app_development
}

# 스테이징 환경 배포
deployment "stg" {
  inputs = {
    # 환경 구분
    environment   = "stg"
    enable_backup = true
    
    # 기본 스택에서 전달받는 네트워크 리소스 (upstream 사용)
    vpc_id                    = upstream.core_infrastructure.stg_vpc_outputs.vpc_id
    public_subnet_ids         = upstream.core_infrastructure.stg_vpc_outputs.public_subnet_ids
    private_subnet_ids        = upstream.core_infrastructure.stg_vpc_outputs.private_subnet_ids
    web_security_group_id     = upstream.core_infrastructure.stg_vpc_outputs.web_security_group_id
    db_security_group_id      = upstream.core_infrastructure.stg_vpc_outputs.db_security_group_id
    ec2_instance_profile_arn  = upstream.core_infrastructure.stg_vpc_outputs.ec2_instance_profile_arn
    
    # 애플리케이션 설정 (하드코딩된 값 - ephemeral 아님)
    instance_type     = "t3.small"
    db_instance_class = "db.t3.small"
    
    # AWS 자격증명 (Variable Sets에서 가져오기)
    aws_access_key_id     = store.varset.aws_credentials.AWS_ACCESS_KEY_ID
    aws_secret_access_key = store.varset.aws_credentials.AWS_SECRET_ACCESS_KEY
    
    # 공통 설정 (하드코딩된 값 - ephemeral 아님)
    aws_region    = "ap-northeast-2"
    project_name  = "terraform-stacks-demo"
    owner         = "devops-team"
    createdBy     = "hj.do"
    cost_center   = "engineering"
    managed_by    = "terraform-stacks"
    name_prefix   = "hjdo"
    
    # 민감한 정보 (Variable Sets에서 관리 - ephemeral)
    db_username  = store.varset.database_config.db_username
    db_password  = store.varset.database_config.db_password
    
    # 임시 민감한 값들 (필요 시에만 사용)
    temp_access_token = ""  # 기본값: 빈 문자열
    deployment_key    = ""  # 기본값: 빈 문자열
  }
  
  deployment_group = deployment_group.app_staging
}

# 프로덕션 환경 배포
deployment "prd" {
  inputs = {
    # 환경 구분
    environment   = "prd"
    enable_backup = true
    
    # 기본 스택에서 전달받는 네트워크 리소스 (upstream 사용)
    vpc_id                    = upstream.core_infrastructure.prd_vpc_outputs.vpc_id
    public_subnet_ids         = upstream.core_infrastructure.prd_vpc_outputs.public_subnet_ids
    private_subnet_ids        = upstream.core_infrastructure.prd_vpc_outputs.private_subnet_ids
    web_security_group_id     = upstream.core_infrastructure.prd_vpc_outputs.web_security_group_id
    db_security_group_id      = upstream.core_infrastructure.prd_vpc_outputs.db_security_group_id
    ec2_instance_profile_arn  = upstream.core_infrastructure.prd_vpc_outputs.ec2_instance_profile_arn
    
    # 애플리케이션 설정 (하드코딩된 값 - ephemeral 아님)
    instance_type     = "t3.medium"
    db_instance_class = "db.t3.medium"
    
    # AWS 자격증명 (Variable Sets에서 가져오기)
    aws_access_key_id     = store.varset.aws_credentials.AWS_ACCESS_KEY_ID
    aws_secret_access_key = store.varset.aws_credentials.AWS_SECRET_ACCESS_KEY
    
    # 공통 설정 (하드코딩된 값 - ephemeral 아님)
    aws_region    = "ap-northeast-2"
    project_name  = "terraform-stacks-demo"
    owner         = "devops-team"
    createdBy     = "hj.do"
    cost_center   = "engineering"
    managed_by    = "terraform-stacks"
    name_prefix   = "hjdo"
    
    # 민감한 정보 (Variable Sets에서 관리 - ephemeral)
    db_username  = store.varset.database_config.db_username
    db_password  = store.varset.database_config.db_password
    
    # 임시 민감한 값들 (필요 시에만 사용)
    temp_access_token = ""  # 기본값: 빈 문자열
    deployment_key    = ""  # 기본값: 빈 문자열
  }
  
  deployment_group = deployment_group.app_production
}
# =============================================================================
# 연결된 스택 배포 정의 (Application Services Stack Deployments)
# =============================================================================

# -----------------------------------------------------------------------------
# Variable Sets 참조 - AWS 인증은 Variable Sets를 통해 관리
# -----------------------------------------------------------------------------
store "varset" "aws_credentials" {
  id       = "varset-aws-credentials-id"  # 실제 Variable Set ID로 교체 필요
  category = "terraform"
}

store "varset" "database_config" {
  id       = "varset-database-config-id"  # 실제 Variable Set ID로 교체 필요
  category = "env"
}

store "varset" "common_tags" {
  id       = "varset-common-tags-id"  # 실제 Variable Set ID로 교체 필요
  category = "terraform"
}

store "varset" "app_config" {
  id       = "varset-app-config-id"  # 실제 Variable Set ID로 교체 필요
  category = "terraform"
}

# -----------------------------------------------------------------------------
# 기본 스택 출력 참조 - upstream_input 블록
# -----------------------------------------------------------------------------
upstream_input "core_infrastructure" {
  stack = "core-infrastructure"
}

# -----------------------------------------------------------------------------
# 배포 그룹 정의 - 기본 스택 완료 후 배포
# -----------------------------------------------------------------------------
deployment_group "app_development" {
  deployments = ["dev"]
  # core-infrastructure 스택의 dev 환경 완료 후 실행
}

deployment_group "app_staging" {
  deployments = ["stg"]
  depends_on = [deployment_group.app_development]
  # core-infrastructure 스택의 stg 환경 완료 후 실행
}

deployment_group "app_production" {
  deployments = ["prd"]
  depends_on = [deployment_group.app_staging]
  # core-infrastructure 스택의 prd 환경 완료 후 실행
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
    
    # 기본 스택에서 전달받는 네트워크 리소스
    vpc_id                    = upstream.core_infrastructure.vpc_outputs.vpc_id
    public_subnet_ids         = upstream.core_infrastructure.vpc_outputs.public_subnet_ids
    private_subnet_ids        = upstream.core_infrastructure.vpc_outputs.private_subnet_ids
    web_security_group_id     = upstream.core_infrastructure.vpc_outputs.web_security_group_id
    db_security_group_id      = upstream.core_infrastructure.vpc_outputs.db_security_group_id
    ec2_instance_profile_arn  = upstream.core_infrastructure.vpc_outputs.ec2_instance_profile_arn
    
    # 애플리케이션 설정 (Variable Sets에서 관리)
    instance_type     = store.varset.app_config.dev_instance_type
    db_instance_class = store.varset.app_config.dev_db_instance_class
    
    # 공통 설정 (Variable Sets에서 관리)
    aws_region   = store.varset.aws_credentials.aws_region
    db_username  = store.varset.database_config.db_username
    db_password  = store.varset.database_config.db_password
    project_name = store.varset.common_tags.project_name
    owner        = store.varset.common_tags.owner
    created_by   = store.varset.common_tags.created_by
    cost_center  = store.varset.common_tags.cost_center
    name_prefix  = store.varset.common_tags.name_prefix
  }
}

# 스테이징 환경 배포
deployment "stg" {
  inputs = {
    # 환경 구분
    environment   = "stg"
    enable_backup = true
    
    # 기본 스택에서 전달받는 네트워크 리소스
    vpc_id                    = upstream.core_infrastructure.vpc_outputs.vpc_id
    public_subnet_ids         = upstream.core_infrastructure.vpc_outputs.public_subnet_ids
    private_subnet_ids        = upstream.core_infrastructure.vpc_outputs.private_subnet_ids
    web_security_group_id     = upstream.core_infrastructure.vpc_outputs.web_security_group_id
    db_security_group_id      = upstream.core_infrastructure.vpc_outputs.db_security_group_id
    ec2_instance_profile_arn  = upstream.core_infrastructure.vpc_outputs.ec2_instance_profile_arn
    
    # 애플리케이션 설정 (Variable Sets에서 관리)
    instance_type     = store.varset.app_config.stg_instance_type
    db_instance_class = store.varset.app_config.stg_db_instance_class
    
    # 공통 설정 (Variable Sets에서 관리)
    aws_region   = store.varset.aws_credentials.aws_region
    db_username  = store.varset.database_config.db_username
    db_password  = store.varset.database_config.db_password
    project_name = store.varset.common_tags.project_name
    owner        = store.varset.common_tags.owner
    created_by   = store.varset.common_tags.created_by
    cost_center  = store.varset.common_tags.cost_center
    name_prefix  = store.varset.common_tags.name_prefix
  }
}

# 프로덕션 환경 배포
deployment "prd" {
  inputs = {
    # 환경 구분
    environment   = "prd"
    enable_backup = true
    
    # 기본 스택에서 전달받는 네트워크 리소스
    vpc_id                    = upstream.core_infrastructure.vpc_outputs.vpc_id
    public_subnet_ids         = upstream.core_infrastructure.vpc_outputs.public_subnet_ids
    private_subnet_ids        = upstream.core_infrastructure.vpc_outputs.private_subnet_ids
    web_security_group_id     = upstream.core_infrastructure.vpc_outputs.web_security_group_id
    db_security_group_id      = upstream.core_infrastructure.vpc_outputs.db_security_group_id
    ec2_instance_profile_arn  = upstream.core_infrastructure.vpc_outputs.ec2_instance_profile_arn
    
    # 애플리케이션 설정 (Variable Sets에서 관리)
    instance_type     = store.varset.app_config.prd_instance_type
    db_instance_class = store.varset.app_config.prd_db_instance_class
    
    # 공통 설정 (Variable Sets에서 관리)
    aws_region   = store.varset.aws_credentials.aws_region
    db_username  = store.varset.database_config.db_username
    db_password  = store.varset.database_config.db_password
    project_name = store.varset.common_tags.project_name
    owner        = store.varset.common_tags.owner
    created_by   = store.varset.common_tags.created_by
    cost_center  = store.varset.common_tags.cost_center
    name_prefix  = store.varset.common_tags.name_prefix
  }
}

# -----------------------------------------------------------------------------
# 자동 승인 정책
# -----------------------------------------------------------------------------
deployment_auto_approve "app_dev_auto_approve" {
  deployment = "dev"
  
  condition {
    max_changes = 5
    reason = "Application dev environment - auto approved for small changes"
  }
}

# stg, prd 환경은 수동 승인 (기본값)
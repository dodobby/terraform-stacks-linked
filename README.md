# Application Services Stack

이 스택은 애플리케이션 서비스 리소스를 관리합니다. EC2, RDS, S3 등 실제 애플리케이션 운영에 필요한 리소스들을 제공하며, Core Infrastructure Stack의 출력을 기반으로 구성됩니다.

## 📋 개요

- **스택 이름**: `application-services`
- **목적**: 애플리케이션 운영 리소스 제공
- **리전**: `ap-northeast-2` (서울)
- **의존성**: `core-infrastructure` 스택의 출력

## 🚀 포함된 리소스

### 컴퓨팅 리소스
- **Application Load Balancer**: 웹 트래픽 분산
- **Auto Scaling Group**: 자동 확장/축소
- **Launch Template**: EC2 인스턴스 템플릿
- **EC2 인스턴스**: Amazon Linux 2023 기반 웹 서버

### 데이터베이스 리소스
- **RDS MySQL 8.0**: 애플리케이션 데이터베이스
- **DB Subnet Group**: 데이터베이스 서브넷 그룹
- **DB Parameter Group**: 데이터베이스 파라미터 최적화

### 스토리지 리소스
- **S3 버킷**: 애플리케이션 파일 저장
- **버킷 정책**: 보안 및 접근 제어
- **라이프사이클 정책**: 비용 최적화 (프로덕션)

## 📁 디렉토리 구조

```
terraform-stacks-linked/
├── main.tfcomponent.hcl           # 스택 컴포넌트 정의
├── deployments.tfdeploy.hcl       # 환경별 배포 설정
├── .terraform-version             # Terraform 버전 고정
├── .gitignore                     # Git 무시 파일
├── README.md                      # 이 파일
├── components/
│   └── applications/              # 애플리케이션 컴포넌트
│       ├── main.tf                # 모듈 호출
│       ├── variables.tf           # 입력 변수
│       ├── outputs.tf             # 출력 값
│       └── providers.tf           # Provider 설정
├── modules/
│   ├── ec2/                       # EC2 + ALB + ASG 모듈
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── user_data.sh           # 인스턴스 초기화 스크립트
│   ├── rds/                       # RDS 모듈
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── s3/                        # S3 모듈
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── config/
    └── application-config.yaml    # 환경별 애플리케이션 설정
```

## 🌍 환경별 설정

### Development (dev)
- **EC2**: `t3.micro` (1개 인스턴스)
- **RDS**: `db.t3.micro`, 백업 비활성화, Single-AZ
- **S3**: 기본 설정, 라이프사이클 정책 없음

### Staging (stg)
- **EC2**: `t3.small` (1-2개 인스턴스)
- **RDS**: `db.t3.small`, 14일 백업, Multi-AZ, Performance Insights
- **S3**: 버전 관리 활성화

### Production (prd)
- **EC2**: `t3.medium` (2-6개 인스턴스)
- **RDS**: `db.t3.medium`, 30일 백업, Multi-AZ, Performance Insights
- **S3**: 버전 관리, 라이프사이클 정책, 알림 설정

## 🔗 Core Stack 의존성

이 스택은 `upstream_input`을 통해 Core Infrastructure Stack의 다음 출력을 사용합니다:

```hcl
upstream.core_infrastructure.vpc_outputs = {
  vpc_id                    # VPC ID
  public_subnet_ids         # ALB용 퍼블릭 서브넷
  private_subnet_ids        # EC2, RDS용 프라이빗 서브넷
  web_security_group_id     # 웹 서버 보안 그룹
  db_security_group_id      # 데이터베이스 보안 그룹
  ec2_instance_profile_arn  # EC2 인스턴스 프로파일
}
```

## 📤 출력 값

이 스택은 다음 출력 값들을 제공합니다:

### 웹 서비스
```hcl
web_server_ids            = "asg-xxxxx"
web_server_private_ips    = ["Auto Scaling Group - IPs are dynamic"]
load_balancer_dns         = "hjdo-app-alb-dev-xxxxx.ap-northeast-2.elb.amazonaws.com"
load_balancer_arn         = "arn:aws:elasticloadbalancing:ap-northeast-2:xxx:loadbalancer/app/xxx"
```

### 데이터베이스
```hcl
database_endpoint         = "hjdo-app-db-dev.xxxxx.ap-northeast-2.rds.amazonaws.com"
database_port            = 3306
database_name            = "appdb"
```

### 스토리지
```hcl
s3_bucket_name           = "hjdo-app-storage-dev-xxxxx"
s3_bucket_arn            = "arn:aws:s3:::hjdo-app-storage-dev-xxxxx"
```

## 🔧 필요한 Variable Sets

이 스택을 배포하기 위해 다음 Variable Sets가 필요합니다:

1. **aws-credentials**: AWS 인증 정보
2. **common-tags**: 공통 태그 설정
3. **database-config**: 데이터베이스 인증 정보
4. **app-config**: 환경별 애플리케이션 설정

## 🚀 배포 방법

### 1. 전제 조건
- Core Infrastructure Stack이 먼저 배포되어야 함
- 필요한 Variable Sets가 설정되어야 함

### 2. 배포 순서
```
core-infrastructure (dev) → application-services (dev)
core-infrastructure (stg) → application-services (stg)  
core-infrastructure (prd) → application-services (prd)
```

### 3. 스택 배포
1. 워크스페이스 생성
2. VCS 연결 (이 리포지토리)
3. Variable Sets 연결
4. `upstream_input` 설정 확인
5. 배포 실행

## 🌐 애플리케이션 접근

### 웹 애플리케이션
배포 완료 후 Load Balancer DNS를 통해 접근:
```
http://hjdo-app-alb-{environment}-xxxxx.ap-northeast-2.elb.amazonaws.com
```

### 애플리케이션 기능
- 환경 정보 표시
- 인스턴스 ID 및 가용 영역 표시
- 간단한 상태 확인 페이지

## 🔒 보안 설정

### 네트워크 보안
- **ALB**: 퍼블릭 서브넷, HTTP/HTTPS 접근
- **EC2**: 프라이빗 서브넷, ALB에서만 접근
- **RDS**: 프라이빗 서브넷, EC2에서만 접근

### 접근 제어
- **SSH**: VPC 내부에서만 접근 가능
- **데이터베이스**: 웹 서버 보안 그룹에서만 접근
- **S3**: IAM 역할 기반 접근

## 📊 모니터링 및 로깅

### CloudWatch 메트릭
- **ALB**: 요청 수, 응답 시간, 오류율
- **Auto Scaling**: 인스턴스 수, CPU 사용률
- **RDS**: 연결 수, CPU, 메모리 사용률
- **S3**: 요청 수, 스토리지 사용량

### 로그 수집
- **ALB 액세스 로그**: S3에 저장
- **EC2 로그**: CloudWatch Logs
- **RDS 로그**: CloudWatch Logs

## 💰 비용 최적화

### 환경별 전략
- **Dev**: 최소 리소스, 업무 시간 외 자동 종료
- **Stg**: 테스트 기간에만 운영
- **Prd**: 예약 인스턴스, 적절한 크기 조정

### Auto Scaling
```hcl
# 환경별 Auto Scaling 설정
dev: min=1, max=2, desired=1
stg: min=1, max=4, desired=1  
prd: min=2, max=6, desired=2
```

## 🛠️ 문제 해결

### 일반적인 문제

1. **Core Stack 의존성 오류**
   ```
   Error: upstream input not found
   ```
   - Core Infrastructure Stack이 배포되었는지 확인
   - `upstream_input` 설정 확인

2. **데이터베이스 연결 실패**
   ```
   Error: database connection failed
   ```
   - 보안 그룹 규칙 확인
   - 데이터베이스 자격증명 확인

3. **Load Balancer 헬스체크 실패**
   ```
   Error: unhealthy targets
   ```
   - EC2 인스턴스 상태 확인
   - 보안 그룹 규칙 확인
   - 애플리케이션 로그 확인

### 디버깅 방법

```bash
# ALB 타겟 상태 확인
aws elbv2 describe-target-health --target-group-arn [target-group-arn]

# RDS 연결 테스트
mysql -h [rds-endpoint] -u admin -p appdb

# S3 버킷 접근 테스트
aws s3 ls s3://[bucket-name]
```

## 🔄 업데이트 및 롤백

### 무중단 배포
- Auto Scaling Group을 통한 롤링 업데이트
- Blue/Green 배포 지원 (ALB 타겟 그룹 교체)

### 백업 및 복구
- **RDS**: 자동 백업 및 스냅샷
- **S3**: 버전 관리 및 Cross-Region 복제 (프로덕션)
- **EC2**: AMI 스냅샷

## 📚 관련 문서

- [Core Infrastructure Stack](../terraform-stacks-core/README.md)
- [Variable Sets 설정 가이드](../terraform-cloud-setup/README.md)
- [Terraform Stacks 의존성 관리](https://developer.hashicorp.com/terraform/cloud-docs/stacks/dependencies)

## 🔄 업데이트 이력

- **v1.0.0**: 초기 버전 생성
- 서울 리전 (ap-northeast-2) 설정
- Core Infrastructure Stack 의존성 설정
- 환경별 Auto Scaling 및 RDS 설정 최적화
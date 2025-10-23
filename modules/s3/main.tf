# S3 Bucket
resource "aws_s3_bucket" "app" {
  bucket = "${var.name_prefix}-app-storage-${var.environment}-${random_id.bucket_suffix.hex}"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-storage-${var.environment}"
    Type = "application-storage"
  })
}

# Random ID for bucket suffix
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id
  versioning_configuration {
    status = var.environment == "prd" ? "Enabled" : "Suspended"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "app" {
  count  = var.environment == "prd" ? 1 : 0
  bucket = aws_s3_bucket.app.id

  rule {
    id     = "transition_to_ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }

  rule {
    id     = "delete_incomplete_multipart_uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# S3 Bucket Notification (선택사항)
resource "aws_s3_bucket_notification" "app" {
  count  = var.environment == "prd" ? 1 : 0
  bucket = aws_s3_bucket.app.id

  # CloudWatch Events를 통한 알림 (실제 구현 시 Lambda 함수 필요)
  # lambda_function {
  #   lambda_function_arn = aws_lambda_function.processor.arn
  #   events              = ["s3:ObjectCreated:*"]
  # }
}
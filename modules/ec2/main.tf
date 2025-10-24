# 최신 Amazon Linux 2023 AMI 조회
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Application Load Balancer (Multi-AZ)
resource "aws_lb" "web" {
  name               = "${var.name_prefix}-app-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-alb-${var.environment}"
    Type = "load-balancer"
  })
}

# ALB Target Group
resource "aws_lb_target_group" "web" {
  name     = "${var.name_prefix}-app-tg-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-tg-${var.environment}"
    Type = "target-group"
  })
}

# ALB Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-listener-${var.environment}"
  })
}

# Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "${var.name_prefix}-app-lt-${var.environment}-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.web_security_group_id]

  iam_instance_profile {
    name = split("/", var.ec2_instance_profile_arn)[1]
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-app-web-${var.environment}"
      Type = "web-server"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-lt-${var.environment}"
    Type = "launch-template"
  })
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "${var.name_prefix}-app-asg-${var.environment}"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.environment == "prd" ? 2 : 1
  max_size         = var.environment == "prd" ? 6 : 2
  desired_capacity = var.environment == "prd" ? 2 : 1

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-app-asg-${var.environment}"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
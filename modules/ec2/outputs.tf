output "web_server_ids" {
  description = "Web server instance IDs (from ASG)"
  value       = [aws_autoscaling_group.web.id]  # 리스트로 변환
}

output "web_server_private_ips" {
  description = "Web server private IP addresses (placeholder for ASG)"
  value       = ["Auto Scaling Group - IPs are dynamic"]
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = aws_lb.web.dns_name
}

output "load_balancer_arn" {
  description = "Load balancer ARN"
  value       = aws_lb.web.arn
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.web.arn
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.web.id
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}
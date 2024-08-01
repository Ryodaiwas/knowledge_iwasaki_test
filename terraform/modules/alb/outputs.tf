output "security_group_id" {
  value = aws_security_group.knowledgebase-test-lb_security_group.id
}
output "target_group_arn" {
  value = aws_lb_target_group.knowledgebase-test-target_group.arn
}
output "dns_name" {
  value       = aws_alb.knowledgebase-test-lb.dns_name
  description = "AWS load balancer DNS Name"
}

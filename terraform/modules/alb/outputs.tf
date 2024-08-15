output "security_group_id" {
  value = aws_security_group.knowledgebase_lb_sg.id
}
output "target_group_arn" {
  value = aws_lb_target_group.knowledgebase_tg.arn
}
output "dns_name" {
  value       = aws_alb.knowledgebase_lb.dns_name
  description = "AWS load balancer DNS Name"
}
output "lb_listener" {
  value       = aws_lb_listener.knowledgebase_listener
  description = "AWS load balancer DNS Name"
}

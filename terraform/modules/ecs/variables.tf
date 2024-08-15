variable "ecr_repository_url" {
  type = string
}
variable "iam_role_arn" {
  type = string
}
variable "security_group_id" {
  type = string
}
variable "target_group_arn" {
  type = string
}
variable "private_subnet_ids" {
  type = set(string)
}
# variable "lb_listener" {
#   type = any
# }

variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy the ECS"
}

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
variable "subnets" {
  type = set(string)
}



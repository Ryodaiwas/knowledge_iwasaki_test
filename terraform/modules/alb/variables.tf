variable "public_subnet_ids" {
  type        = set(string)
  description = "List of subnets to deploy the ALB"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy the ALB"
}

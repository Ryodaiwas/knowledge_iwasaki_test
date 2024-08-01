output "subnets" {
  value = [
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_d.id,
    aws_default_subnet.default_subnet_c.id
  ]
}
output "vpc_id" {
  value = aws_default_vpc.default_vpc.id
}

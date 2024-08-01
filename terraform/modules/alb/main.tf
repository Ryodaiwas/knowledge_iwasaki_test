# Creating a load balancer
resource "aws_alb" "knowledgebase-test-lb" {
  name               = "knowledgebase-test-lb" # Naming our load balancer
  load_balancer_type = "application"
  # subnets = [ # Referencing the default subnets
  #   "${aws_default_subnet.default_subnet_a.id}",
  #   "${aws_default_subnet.default_subnet_d.id}",
  #   "${aws_default_subnet.default_subnet_c.id}"
  # ]
  subnets = var.subnets
  # Referencing the security group
  security_groups = [aws_security_group.knowledgebase-test-lb_security_group.id]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "knowledgebase-test-lb_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating a target group for the load balancer
resource "aws_lb_target_group" "knowledgebase-test-target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  #   vpc_id      = aws_default_vpc.default_vpc.id # Referencing the default VPC

  health_check {
    matcher = "200,301,302"
    path    = "/"
  }
}

# Creating a listener for the load balancer
resource "aws_lb_listener" "knowledgebase-test-listener" {
  load_balancer_arn = aws_alb.knowledgebase-test-lb.arn # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.knowledgebase-test-target_group.arn # Referencing our target group
  }
}



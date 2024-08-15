
# Load Balancerの作成
resource "aws_alb" "knowledgebase_lb" {
  name               = "knowledgebase-lb" # ロードバランサーの名前
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.knowledgebase_lb_sg.id]

}

# Load Balancer用のセキュリティグループの作成
resource "aws_security_group" "knowledgebase_lb_sg" {
  vpc_id = var.vpc_id
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


# Load Balancer用のターゲットグループの作成
resource "aws_lb_target_group" "knowledgebase_tg" {
  name        = "knowledgebase-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    interval = 30        # 30秒に設定
    matcher  = "200-302" # HTTPステータスコードの範囲を指定
    path     = "/"
  }
}


# Load Balancerのリスナーの作成
resource "aws_lb_listener" "knowledgebase_listener" {
  load_balancer_arn = aws_alb.knowledgebase_lb.arn # ロードバランサーの参照
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.knowledgebase_tg.arn # ターゲットグループの参照
  }
}

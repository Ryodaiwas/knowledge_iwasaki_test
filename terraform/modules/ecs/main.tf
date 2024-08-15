# ECSクラスターの作成
resource "aws_ecs_cluster" "knowledgebase_cluster" {
  name = "knowledgebase-cluster" # クラスターの名前
}

# ECSタスク定義の作成
resource "aws_ecs_task_definition" "knowledgebase_task_definition" {
  family                   = "knowledgebase-task" # タスクの名前
  container_definitions    = <<DEFINITION
  [
    {
      "name": "knowledgebase-container",
      "image": "${var.ecr_repository_url}",  
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]      # Fargateを使用
  network_mode             = "awsvpc"         # awsvpcネットワークモード
  memory                   = 512              # タスクのメモリ
  cpu                      = 256              # タスクのCPU
  execution_role_arn       = var.iam_role_arn # 実行ロールのARN
}

# ECSサービスの作成
resource "aws_ecs_service" "knowledgebase_ecs_service" {
  name            = "knowledgebase-service"
  cluster         = aws_ecs_cluster.knowledgebase_cluster.id                  # クラスターの参照
  task_definition = aws_ecs_task_definition.knowledgebase_task_definition.arn # タスク定義の参照
  launch_type     = "FARGATE"
  desired_count   = 3 # コンテナのデプロイ数
  # depends_on      = [var.lb_listener]

  load_balancer {
    target_group_arn = var.target_group_arn # ターゲットグループの参照
    container_name   = "knowledgebase-container"
    container_port   = 3000 # コンテナポートの指定
  }

  network_configuration {
    subnets          = var.private_subnet_ids                           # サブネットの参照
    assign_public_ip = true                                             # パブリックIPの割り当て
    security_groups  = [aws_security_group.knowledgebase_service_sg.id] # セキュリティグループの設定
  }
}

# ECSサービス用セキュリティグループの作成
resource "aws_security_group" "knowledgebase_service_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # ロードバランサーのセキュリティグループからのトラフィックのみ許可
    security_groups = [var.security_group_id]
  }

  egress {
    from_port   = 0             # すべてのインバウンドポートを許可
    to_port     = 0             # すべてのアウトバウンドポートを許可
    protocol    = "-1"          # すべてのアウトバウンドプロトコルを許可
    cidr_blocks = ["0.0.0.0/0"] # すべてのIPアドレスへのトラフィックを許可
  }
}

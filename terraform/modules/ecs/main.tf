resource "aws_ecs_cluster" "knowledgebase-test-cluster" {
  name = "knowledgebase-test-cluster" # Naming the cluster
}


resource "aws_ecs_task_definition" "knowledgebase-test-task-test" {
  family                   = "knowledgebase-test-task-test" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "knowledgebase-test-container",
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
  requires_compatibilities = ["FARGATE"]      # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"         # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512              # Specifying the memory our task requires
  cpu                      = 256              # Specifying the CPU our task requires
  execution_role_arn       = var.iam_role_arn # Stating Amazon Resource Name (ARN) of the execution role
}


# Creating the service
resource "aws_ecs_service" "knowledgebase-test-service" {
  name            = "knowledgebase-test-service"
  cluster         = aws_ecs_cluster.knowledgebase-test-cluster.id            # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.knowledgebase-test-task-test.arn # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers we want deployed to 3

  load_balancer {
    target_group_arn = var.target_group_arn # Referencing our target group
    container_name   = "knowledgebase-test-container"
    container_port   = 3000 # Specifying the container port
  }

  network_configuration {
    subnets          = var.subnets                                                            # Referencing the subnets
    assign_public_ip = true                                                                   # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.knowledgebase-test-service_security_group.id}"] # Setting the security group
  }
}

# Creating a security group for the service
resource "aws_security_group" "knowledgebase-test-service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [var.security_group_id]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_security_group" "lb" {
  name   = "hackaton-alb-security-group"
  vpc_id = aws_vpc.default.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "default" {
  name            = "app-lb"
  subnets         = ["subnet-0eb82f677fa7aecda", "subnet-04e3879cbe81fe8db"]
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "hackaton" {
  name        = "app-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.default.id
  target_type = "ip"
}

resource "aws_lb_listener" "hackaton" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.hackaton.id
    type             = "forward"
  }
}

resource "aws_ecs_task_definition" "hackaton" {
  family                   = "hackaton-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = "arn:aws:iam::771282812019:role/ecsInstanceRole"
  execution_role_arn       = "arn:aws:iam::771282812019:role/ecsInstanceRole"
  container_definitions    = <<DEFINITION
[
  {
    "image" : "hello-world",
    "cpu": 1024,
    "memory": 2048,
    "name": "hackaton-app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-create-group": "true",
          "awslogs-group": "hackaton",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
  }
]
DEFINITION
}

resource "aws_security_group" "hackaton_task" {
  name   = "hackaton-task-security-group"
  vpc_id = aws_vpc.default.id

  ingress {
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [aws_security_group.lb.id]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["10.32.1.0/24", "10.32.0.0/24"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_service" "hackaton" {
  name            = "hackaton-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hackaton.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.hackaton_task.id]
    subnets         = var.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.hackaton.id
    container_name   = "hackaton-app"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.hackaton]
}

output "load_balancer_ip" {
  value = aws_lb.default.dns_name
}

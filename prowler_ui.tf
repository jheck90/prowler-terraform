#trivy:ignore:AVD-AWS-0036
resource "aws_ecs_task_definition" "ui" {
  family                   = "prowler-ui"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "prowler-ui"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com/prowler-ui:${var.prowler_ui_version}"
      essential = true
      portMappings = [
        {
          name          = "prowler-ui-port"
          containerPort = var.ui_port
          hostPort      = var.ui_port
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "HOSTNAME", value = "0.0.0.0" },
        { name = "PORT", value = "3000" },
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.prowler_ui.name
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "ui"
        }
      }
    }
  ])
}

# ECS Service for UI
resource "aws_ecs_service" "ui" {
  name                              = "prowler-ui"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.ui.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  enable_execute_command            = true
  health_check_grace_period_seconds = 120

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.ui_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ui.arn
    container_name   = "prowler-ui"
    container_port   = var.ui_port
  }
  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.service_connect.name

    service {
      port_name      = "prowler-ui-port"
      discovery_name = "prowler-ui"

      client_alias {
        port     = 3000
        dns_name = "ui.prowler-app.local"
      }
    }
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = false
  }
  depends_on = [
    aws_lb_listener_rule.ui,
  ]
}

# UI Load Balancer Target Group
resource "aws_lb_target_group" "ui" {
  name        = "prowler-ui-tg"
  port        = var.ui_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/api/heatlh" # Simple endpoint that always returns 200
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2         # Minimum number of consecutive successful checks
    unhealthy_threshold = 5         # Number of consecutive failed checks before marking unhealthy
    timeout             = 10        # Seconds to wait for a response
    interval            = 30        # Seconds between health checks
    matcher             = "200-499" # Consider any 2XX or 3XX response as healthy
  }
}

# Load Balancer Listener Rule for UI
resource "aws_lb_listener_rule" "ui" {
  listener_arn = aws_lb_listener.public_secure.arn
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ui.arn
  }
  condition {
    host_header {
      values = ["${var.ui_domain}"]
    }
  }
}

# Security Group for UI service
# TODO
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "ui_sg" {
  name        = "prowler-ui-sg"
  description = "Security group for Prowler UI"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = var.ui_port
    to_port         = var.ui_port
    protocol        = "tcp"
    security_groups = [aws_security_group.public_alb.id]
  }
  ingress {
    description = "Allow traffic from All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Database access (if needed)
  ingress {
    description = "Allow Traffic from Postgres"
    from_port   = var.postgres_port
    to_port     = var.postgres_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow Traffic from Valkey"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "prowler-ui-sg"
    Environment = var.environment
  }
}

# CloudWatch Log Group for UI
resource "aws_cloudwatch_log_group" "prowler_ui" {
  name              = "/ecs/prowler-ui"
  retention_in_days = 30
  kms_key_id        = aws_kms_key.ecs_logs.arn
}

# Additional secrets for UI
resource "aws_secretsmanager_secret" "auth_secret" {
  name = "prowler/auth_secret2"
}

resource "aws_secretsmanager_secret_version" "auth_secret_value" {
  secret_id     = aws_secretsmanager_secret.auth_secret.id
  secret_string = var.auth_secret
}

# Update the secrets access policy to include UI secrets
resource "aws_iam_policy" "ui_secrets_access" {
  name        = "prowler-ui-secrets-access"
  description = "Allow access to Prowler UI secrets in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["secretsmanager:GetSecretValue"]
        Effect = "Allow"
        Resource = [
          aws_secretsmanager_secret.auth_secret.arn,
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ui_secrets_access_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ui_secrets_access.arn
}

# CloudWatch Logs policy for ECS execution role
resource "aws_iam_policy" "ecs_logs_policy" {
  name        = "prowler-ecs-logs-policy"
  description = "Policy to allow ECS tasks to write to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:/ecs/*",
          "arn:aws:logs:*:*:log-group:/ecs/*:log-stream:*"
        ]
      }
    ]
  })
}

# Attach the logs policy to the execution role
resource "aws_iam_role_policy_attachment" "ecs_logs_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_logs_policy.arn
}

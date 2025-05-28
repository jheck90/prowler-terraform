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
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/prowler-ui:${var.prowler_ui_version}"
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
        { name = "PROWLER_UI_VERSION", value = var.prowler_ui_version },
        { name = "AUTH_URL", value = "https://${var.ui_domain}" },
        { name = "API_BASE_URL", value = "https://${var.api_domain}/api/v1" },
        { name = "NEXT_PUBLIC_API_DOCS_URL", value = "https://${var.api_domain}/api/v1/docs" },
        { name = "AUTH_TRUST_HOST", value = "true" },
        { name = "DJANGO_BIND_ADDRESS", value = "0.0.0.0" },
        # { name = "UI_PORT", value = tostring(var.ui_port) },
        # { name = "NEXT_PUBLIC_PROWLER_RELEASE_VERSION", value = var.prowler_release_version },

        # Social login settings - these could be moved to secrets if needed
        # { name = "SOCIAL_GOOGLE_OAUTH_CALLBACK_URL", value = "${var.api_domain}/api/auth/callback/google" },
        # { name = "SOCIAL_GITHUB_OAUTH_CALLBACK_URL", value = "${var.api_domain}/api/auth/callback/github" }
      ],
      secrets = [
        { name = "AUTH_SECRET", valueFrom = aws_secretsmanager_secret.auth_secret.arn },
        # { name = "SOCIAL_GOOGLE_OAUTH_CLIENT_ID", valueFrom = aws_secretsmanager_secret.google_oauth_client_id.arn },
        # { name = "SOCIAL_GOOGLE_OAUTH_CLIENT_SECRET", valueFrom = aws_secretsmanager_secret.google_oauth_client_secret.arn },
        # { name = "SOCIAL_GITHUB_OAUTH_CLIENT_ID", valueFrom = aws_secretsmanager_secret.github_oauth_client_id.arn },
        # { name = "SOCIAL_GITHUB_OAUTH_CLIENT_SECRET", valueFrom = aws_secretsmanager_secret.github_oauth_client_secret.arn }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.prowler_ui.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ui"
        }
      }
    }
  ])
}

# ECS Service for UI
resource "aws_ecs_service" "ui" {
  name                   = "prowler-ui"
  cluster                = aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.ui.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

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
    namespace = aws_service_discovery_private_dns_namespace.prowler.arn
    service {
      client_alias {
        port     = 3000
        dns_name = "dprowler-ui"
      }
      port_name      = "prowler-ui-port"
      discovery_name = "prowler-ui"
    }
  }
  depends_on = [
    aws_lb_listener_rule.ui,
    aws_iam_role_policy_attachment.ecs_execution_role_policy
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
    path                = "/" # Simple endpoint that always returns 200
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
    description = "Allow Traffic from VPC"
    from_port   = var.postgres_port
    to_port     = var.postgres_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  ingress {
    description = "Allow Traffic from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block, var.vpn_cidr]
  }

  ingress {
    description = "Allow Traffic from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block, var.vpn_cidr]
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

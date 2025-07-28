# ECS Task Definition for Worker-Beat service
resource "aws_ecs_task_definition" "worker_beat" {
  family                   = "prowler-worker-beat"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "prowler-worker-beat"
      image        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com/prowler-api:${var.prowler_api_version}"
      essential    = true
      portMappings = [] # Worker-beat doesn't expose ports
      environment = [
        # Core settings
        { name = "PROWLER_API_VERSION", value = var.prowler_api_version },
        { name = "DJANGO_LOGGING_FORMATTER", value = var.django_logging_formatter },
        { name = "DJANGO_LOGGING_LEVEL", value = var.django_logging_level },
        { name = "DJANGO_SETTINGS_MODULE", value = var.django_settings_module },
        { name = "DJANGO_DEBUG", value = "True" },

        # DB settings
        { name = "POSTGRES_HOST", value = local.postgres_host_only },
        { name = "POSTGRES_PORT", value = tostring(var.postgres_port) },
        { name = "POSTGRES_ADMIN_USER", value = var.postgres_user },
        { name = "POSTGRES_USER", value = var.postgres_user },
        { name = "POSTGRES_DB", value = var.postgres_db },

        # Valkey/Redis settings
        { name = "VALKEY_HOST", value = local.valkey_host_only },
        { name = "VALKEY_PORT", value = tostring(var.valkey_port) },
        { name = "VALKEY_DB", value = tostring(var.valkey_db) },
        { name = "VALKEY_SSL", value = "true" },

        # Worker-beat specific settings
        { name = "DJANGO_BROKER_VISIBILITY_TIMEOUT", value = tostring(var.django_broker_visibility_timeout) }
      ],
      secrets = [
        { name = "POSTGRES_ADMIN_PASSWORD", valueFrom = aws_secretsmanager_secret.postgres_admin_password.arn },
        { name = "POSTGRES_PASSWORD", valueFrom = aws_secretsmanager_secret.postgres_password.arn },
        { name = "DJANGO_TOKEN_SIGNING_KEY", valueFrom = aws_secretsmanager_secret.django_token_signing_key.arn },
        { name = "DJANGO_TOKEN_VERIFYING_KEY", valueFrom = aws_secretsmanager_secret.django_token_verifying_key.arn },
        { name = "DJANGO_SECRETS_ENCRYPTION_KEY", valueFrom = aws_secretsmanager_secret.django_secrets_encryption_key.arn }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.prowler_worker_beat.name
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "worker-beat"
        }
      },
      entryPoint = ["../docker-entrypoint.sh"],
      command    = ["beat"]
    }
  ])
}

# ECS Service for Worker-Beat
resource "aws_ecs_service" "worker_beat" {
  name                   = "prowler-worker-beat"
  cluster                = aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.worker_beat.arn
  desired_count          = 1 # Beat services usually only need 1 instance
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.worker_beat_sg.id]
    assign_public_ip = false
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = false
  }
}

# Security Group for Worker-Beat service
# TODO
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "worker_beat_sg" {
  name        = "prowler-worker-beat-sg"
  description = "Security group for Prowler Worker-Beat"
  vpc_id      = data.aws_vpc.main.id

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
    Name        = "prowler-worker-beat-sg"
    Environment = var.environment
  }
}

# CloudWatch Log Group for Worker-Beat
resource "aws_cloudwatch_log_group" "prowler_worker_beat" {
  name              = "/ecs/prowler-worker-beat"
  retention_in_days = 30
}


# IAM Role for Event Rule
resource "aws_iam_role" "event_role" {
  name = "prowler-event-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "event_policy" {
  name = "prowler-event-policy"
  role = aws_iam_role.event_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ecs:RunTask"]
        Effect   = "Allow"
        Resource = aws_ecs_task_definition.worker_beat.arn
      },
      {
        Action   = ["iam:PassRole"]
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringLike = {
            "iam:PassedToService" : "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}

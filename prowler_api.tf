locals {
  postgres_endpoint_full = aws_db_instance.postgres.endpoint
  valkey_endpoint_full   = aws_elasticache_replication_group.valkey.primary_endpoint_address
  postgres_host_only     = split(":", aws_db_instance.postgres.endpoint)[0]
  valkey_host_only       = split(":", aws_elasticache_replication_group.valkey.primary_endpoint_address)[0]
}


# ECS Task Definition for API service
#trivy:ignore:AVD-AWS-0036
resource "aws_ecs_task_definition" "api" {
  family                   = "prowler-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu    = 2048
  memory = 4096

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn



  container_definitions = jsonencode([
    {
      name      = "prowler-api"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com/prowler-api:${var.prowler_api_version}"
      essential = true
      portMappings = [
        {
          name          = "prowler-api-port"
          containerPort = var.django_port
          hostPort      = var.django_port
          protocol      = "tcp"
        }
      ]
      environment = [
        # Core API settings
        { name = "PROWLER_API_VERSION", value = var.prowler_api_version },
        # { name = "DJANGO_ALLOWED_HOSTS", value = var.django_allowed_hosts },
        { name = "DJANGO_ALLOWED_HOSTS", value = "*" },
        { name = "DJANGO_BIND_ADDRESS", value = "0.0.0.0" },
        { name = "DJANGO_PORT", value = tostring(var.django_port) },
        # { name = "DJANGO_DEBUG", value = tostring(var.django_debug) },
        { name = "DJANGO_DEBUG", value = "True" },
        { name = "DJANGO_SETTINGS_MODULE", value = var.django_settings_module },
        { name = "DJANGO_LOGGING_FORMATTER", value = var.django_logging_formatter },
        { name = "DJANGO_LOGGING_LEVEL", value = var.django_logging_level },
        { name = "DJANGO_WORKERS", value = tostring(var.django_workers) },
        { name = "DJANGO_TMP_OUTPUT_DIRECTORY", value = "/tmp/prowler_api_output" },
        { name = "DJANGO_FINDINGS_BATCH_SIZE", value = tostring(var.django_findings_batch_size) },

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

        # Token and Security Settings
        { name = "DJANGO_ACCESS_TOKEN_LIFETIME", value = tostring(var.django_access_token_lifetime) },
        { name = "DJANGO_REFRESH_TOKEN_LIFETIME", value = tostring(var.django_refresh_token_lifetime) },
        { name = "DJANGO_CACHE_MAX_AGE", value = tostring(var.django_cache_max_age) },
        { name = "DJANGO_STALE_WHILE_REVALIDATE", value = tostring(var.django_stale_while_revalidate) },
        { name = "DJANGO_MANAGE_DB_PARTITIONS", value = tostring(var.django_manage_db_partitions) },
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
          "awslogs-group"         = aws_cloudwatch_log_group.prowler_api.name
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "api"
        }
      },
      command = ["/home/prowler/docker-entrypoint.sh", "prod"]
    }
  ])
}

# ECS Service for API
resource "aws_ecs_service" "api" {
  name                              = "prowler-api"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.api.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  enable_execute_command            = true
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.api_sg.id]
    assign_public_ip = false
  }

  #   load_balancer {
  #     target_group_arn = aws_lb_target_group.api.arn
  #     container_name   = "prowler-api"
  #     container_port   = var.django_port
  #   }
  deployment_circuit_breaker {
    enable   = true
    rollback = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.service_connect.name
    service {
      port_name      = "prowler-api-port"
      discovery_name = "prowler-api"

      client_alias {
        port     = 8080
        dns_name = "api.prowler-app.local"
      }
    }
  }
}

# API Load Balancer Target Group
# resource "aws_lb_target_group" "api" {
#   name        = "prowler-api-tg"
#   port        = var.django_port
#   protocol    = "HTTP"
#   vpc_id      = data.aws_vpc.main.id
#   target_type = "ip"

#   health_check {
#     path                = "/api/v1/" # Simple endpoint that always returns 200
#     port                = "traffic-port"
#     protocol            = "HTTP"
#     healthy_threshold   = 2         # Minimum number of consecutive successful checks
#     unhealthy_threshold = 5         # Number of consecutive failed checks before marking unhealthy
#     timeout             = 10        # Seconds to wait for a response
#     interval            = 30        # Seconds between health checks
#     matcher             = "200-499" # Consider any 2XX or 3XX response as healthy
#   }
# }

# # Load Balancer Listener Rule for API
# resource "aws_lb_listener_rule" "api" {
#   listener_arn = aws_lb_listener.public_secure.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.api.arn
#   }
#   condition {
#     host_header {
#       values = ["prowler-api.cisdev.i3verticals.cloud"]
#     }
#   }
# }

# Security Group for API service
# TODO
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "api_sg" {
  name        = "prowler-api-sg"
  description = "Security group for Prowler API"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = var.django_port
    to_port         = var.django_port
    protocol        = "tcp"
    security_groups = [aws_security_group.public_alb.id]
  }
  ingress {
    description = "Allow traffic from VPC"
    from_port   = var.django_port
    to_port     = var.django_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block, var.vpn_cidr]
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
    Name        = "prowler-api-sg"
    Environment = var.environment
  }
}

# CloudWatch Log Group for API
resource "aws_cloudwatch_log_group" "prowler_api" {
  name              = "/ecs/prowler-api"
  retention_in_days = 30
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "prowler-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for ECS Exec functionality
resource "aws_iam_policy" "ecs_exec_policy" {
  name        = "prowler-ecs-exec-policy"
  description = "Policy to allow ECS Exec functionality for container access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to your existing task role
resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}

# IAM Role Policy for ECS Task Execution
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# Make sure this exists and is properly applied
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# Additional policy for Secrets Manager access
resource "aws_iam_policy" "secrets_access" {
  name        = "prowler-secrets-access"
  description = "Allow access to Prowler secrets in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["secretsmanager:GetSecretValue"]
        Effect = "Allow"
        Resource = [
          aws_secretsmanager_secret.postgres_admin_password.arn,
          aws_secretsmanager_secret.postgres_password.arn,
          aws_secretsmanager_secret.django_token_signing_key.arn,
          aws_secretsmanager_secret.django_token_verifying_key.arn,
          aws_secretsmanager_secret.django_secrets_encryption_key.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_access_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

# IAM Role for ECS Tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "prowler-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "prowler_assume_role_permission" {
  name = "prowler-assume-role-permission"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ProwlerScan"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_prowler_assume_role" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.prowler_assume_role_permission.arn
}


# Secrets for sensitive information
resource "aws_secretsmanager_secret" "postgres_admin_password" {
  name = "prowler/postgres_admin_password2"
}

resource "aws_secretsmanager_secret_version" "postgres_admin_password_value" {
  secret_id     = aws_secretsmanager_secret.postgres_admin_password.id
  secret_string = var.postgres_admin_password
}

resource "aws_secretsmanager_secret" "postgres_password" {
  name = "prowler/postgres_password2"
}

resource "aws_secretsmanager_secret_version" "postgres_password_value" {
  secret_id     = aws_secretsmanager_secret.postgres_password.id
  secret_string = var.postgres_password
}

resource "aws_secretsmanager_secret" "django_token_signing_key" {
  name = "prowler/django_token_signing_key2"
}

resource "aws_secretsmanager_secret_version" "django_token_signing_key_value" {
  secret_id     = aws_secretsmanager_secret.django_token_signing_key.id
  secret_string = var.django_token_signing_key
}

resource "aws_secretsmanager_secret" "django_token_verifying_key" {
  name = "prowler/django_token_verifying_key2"
}

resource "aws_secretsmanager_secret_version" "django_token_verifying_key_value" {
  secret_id     = aws_secretsmanager_secret.django_token_verifying_key.id
  secret_string = var.django_token_verifying_key
}

resource "aws_secretsmanager_secret" "django_secrets_encryption_key" {
  name = "prowler/django_secrets_encryption_key2"
}

resource "aws_secretsmanager_secret_version" "django_secrets_encryption_key_value" {
  secret_id     = aws_secretsmanager_secret.django_secrets_encryption_key.id
  secret_string = var.django_secrets_encryption_key
}

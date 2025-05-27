# ECS Task Definition for Worker service
resource "aws_ecs_task_definition" "worker" {
  family                   = "prowler-worker"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "prowler-worker"
      image        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/prowler-api:${var.prowler_api_version}"
      essential    = true
      portMappings = [] # Worker doesn't expose ports
      environment = [
        # Core worker settings
        { name = "PROWLER_API_VERSION", value = var.prowler_api_version },
        { name = "DJANGO_LOGGING_FORMATTER", value = var.django_logging_formatter },
        { name = "DJANGO_LOGGING_LEVEL", value = var.django_logging_level },
        { name = "DJANGO_TMP_OUTPUT_DIRECTORY", value = "/tmp/prowler_api_output" },
        { name = "DJANGO_FINDINGS_BATCH_SIZE", value = tostring(var.django_findings_batch_size) },
        { name = "DJANGO_SETTINGS_MODULE", value = var.django_settings_module },

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

        # S3 output settings (if needed)
        { name = "DJANGO_OUTPUT_S3_AWS_DEFAULT_REGION", value = data.aws_region.current.name },

        # Worker specific settings
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
          "awslogs-group"         = aws_cloudwatch_log_group.prowler_worker.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "worker"
        }
      },
      command = ["/home/prowler/docker-entrypoint.sh", "worker"]
    }
  ])

  # Add ephemeral storage configuration if needed
  ephemeral_storage {
    size_in_gib = 30
  }
}

# ECS Service for Worker
resource "aws_ecs_service" "worker" {
  name                   = "prowler-worker"
  cluster                = data.aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.worker.arn
  desired_count          = 1 # Adjust based on load requirements
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.worker_sg.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.prowler_worker.arn
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution_role_policy
  ]
}

# Security Group for Worker service
# TODO
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "worker_sg" {
  name        = "prowler-worker-sg"
  description = "Security group for Prowler Worker"
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
    Name        = "prowler-worker-sg"
    Environment = var.environment
  }
}

# CloudWatch Log Group for Worker
resource "aws_cloudwatch_log_group" "prowler_worker" {
  name              = "/ecs/prowler-worker"
  retention_in_days = 30
}

# Additional IAM permissions for Worker to access S3 if needed
resource "aws_iam_policy" "worker_s3_access" {
  name        = "prowler-worker-s3-access"
  description = "Allow Prowler Worker to access S3 for scan outputs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.output_s3_bucket}",
          "arn:aws:s3:::${var.output_s3_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_s3_access" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.worker_s3_access.arn
}

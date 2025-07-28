# ECR Repository for Prowler API
resource "aws_ecr_repository" "prowler_api" {
  name                 = "prowler-api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "prowler-api"
    Environment = var.environment
  }
}

# ECR Repository for Prowler UI
resource "aws_ecr_repository" "prowler_ui" {
  name                 = "prowler-ui"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "prowler-ui"
    Environment = var.environment
  }
}

# Lifecycle policy for ECR repositories to limit the number of untagged images
resource "aws_ecr_lifecycle_policy" "api_untagged_cleanup" {
  repository = aws_ecr_repository.prowler_api.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire untagged images older than 14 days",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 14
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "ui_untagged_cleanup" {
  repository = aws_ecr_repository.prowler_ui.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire untagged images older than 14 days",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 14
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Output the repository URLs for easy reference
output "ecr_repository_urls" {
  value = {
    prowler_api = aws_ecr_repository.prowler_api.repository_url
    prowler_ui  = aws_ecr_repository.prowler_ui.repository_url
  }
  description = "URLs of the ECR repositories"
}

# IAM policy to allow pushing/pulling images to these repositories
resource "aws_iam_policy" "ecr_access" {
  name        = "prowler-ecr-access"
  description = "Policy to allow push/pull access to Prowler ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = [
          aws_ecr_repository.prowler_api.arn,
          aws_ecr_repository.prowler_ui.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# Update ECS execution role to allow pulling from ECR
resource "aws_iam_role_policy_attachment" "ecs_ecr_access" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecr_access.arn
}

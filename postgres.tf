resource "aws_db_instance" "postgres" {
  identifier             = "prowler-postgres"
  instance_class         = "db.t4g.medium"
  engine                 = "postgres" # Regular PostgreSQL, not Aurora
  engine_version         = "16.3"
  allocated_storage      = 100
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  db_name                = var.postgres_db
  username               = "postgres"
  password               = var.postgres_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  storage_encrypted      = true
  storage_type           = "gp3"
  multi_az               = false


  tags = {
    Name        = "prowler-postgres"
    Environment = var.environment
  }
  lifecycle {
    ignore_changes = [engine_version]
  }
}


# DB Subnet Group
resource "aws_db_subnet_group" "postgres" {
  name       = "prowler-postgres-subnet-group"
  subnet_ids = data.aws_subnets.protected.ids

  tags = {
    Name        = "Prowler PostgreSQL Subnet Group"
    Environment = var.environment
  }
}

# Security Group for PostgreSQL
# TODO
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "postgres_sg" {
  name        = "prowler-postgres-sg"
  description = "Security group for Prowler PostgreSQL"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "Allow PostgreSQL from VPC"
    from_port   = var.postgres_port
    to_port     = var.postgres_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block, var.vpn_cidr]
  }
  ingress {
    description     = "Allow Valkey from API"
    from_port       = var.valkey_port
    to_port         = var.valkey_port
    protocol        = "tcp"
    security_groups = [aws_security_group.api_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "prowler-postgres-sg"
    Environment = var.environment
  }
}


# CloudWatch Log Group for PostgreSQL logs
resource "aws_cloudwatch_log_group" "postgres_logs" {
  name              = "/aws/rds/cluster/prowler-postgres/postgresql"
  retention_in_days = 30

  tags = {
    Name        = "prowler-postgres-logs"
    Environment = var.environment
  }
}

# Export PostgreSQL configuration as SSM parameters for easier management
resource "aws_ssm_parameter" "postgres_host" {
  name  = "/prowler/postgres/host"
  type  = "String"
  value = aws_db_instance.postgres.endpoint

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "postgres_port" {
  name  = "/prowler/postgres/port"
  type  = "String"
  value = var.postgres_port

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "postgres_db" {
  name  = "/prowler/postgres/db"
  type  = "String"
  value = var.postgres_db

  tags = {
    Environment = var.environment
  }
}

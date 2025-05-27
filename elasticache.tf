resource "aws_elasticache_replication_group" "valkey" {
  replication_group_id       = "prowler"
  description                = "ElastiCache replication group for Prowler Valkey"
  node_type                  = "cache.t3.micro"
  port                       = var.valkey_port
  parameter_group_name       = aws_elasticache_parameter_group.valkey.name
  automatic_failover_enabled = false
  engine                     = "valkey"
  engine_version             = "8.0"
  subnet_group_name          = aws_elasticache_subnet_group.valkey.name
  security_group_ids         = [aws_security_group.valkey_sg.id]
  num_cache_clusters         = 1
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = {
    Name        = "prowler-valkey"
    Environment = var.environment
  }
}

# ElastiCache Parameter Group for Valkey
resource "aws_elasticache_parameter_group" "valkey" {
  name        = "prowler-valkey-params"
  family      = "valkey8"
  description = "Parameter group for Prowler Valkey"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = {
    Name        = "prowler-valkey-params"
    Environment = var.environment
  }
}

# ElastiCache Subnet Group for Valkey
resource "aws_elasticache_subnet_group" "valkey" {
  name       = "prowler-valkey-subnet-group"
  subnet_ids = data.aws_subnets.protected.ids

  tags = {
    Name        = "prowler-valkey-subnet-group"
    Environment = var.environment
  }
}

# Security Group for Valkey
# TODO
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "valkey_sg" {
  name        = "prowler-valkey-sg"
  description = "Security group for Prowler Valkey"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description     = "Allow Valkey from API"
    from_port       = var.valkey_port
    to_port         = var.valkey_port
    protocol        = "tcp"
    security_groups = [aws_security_group.api_sg.id]
  }

  ingress {
    description     = "Allow Valkey from worker"
    from_port       = var.valkey_port
    to_port         = var.valkey_port
    protocol        = "tcp"
    security_groups = [aws_security_group.worker_sg.id]
  }

  ingress {
    description     = "Allow Valkey from worker-beat"
    from_port       = var.valkey_port
    to_port         = var.valkey_port
    protocol        = "tcp"
    security_groups = [aws_security_group.worker_beat_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "prowler-valkey-sg"
    Environment = var.environment
  }
}

# Export Valkey configuration as SSM parameters for easier management
resource "aws_ssm_parameter" "valkey_host" {
  name  = "/prowler/valkey/host"
  type  = "String"
  value = aws_elasticache_replication_group.valkey.primary_endpoint_address

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "valkey_port" {
  name  = "/prowler/valkey/port"
  type  = "String"
  value = var.valkey_port

  tags = {
    Environment = var.environment
  }
}

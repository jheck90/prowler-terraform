data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Environment"
    values = [var.environment]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  tags = {
    Environment = var.environment
    Network     = "private"
  }
}

data "aws_route_tables" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  tags = {
    Environment = var.environment
    Network     = "private"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  tags = {
    Environment = var.environment
    Network     = "public"
  }
}

data "aws_subnets" "protected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Network"
    values = ["protected"]
  }
}

data "aws_ecs_cluster" "main" {
  cluster_name = "prowler-ecs-cluster"
  depends_on   = [aws_ecs_cluster.main]
}


# TODO
data "aws_lb_listener" "main" {
  arn = "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener/app/public-alb/[redacted]/[redacted]"
}

data "aws_lb" "main" {
  arn = "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:loadbalancer/app/public-alb/[redacted]"
}


data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.2025*-x86_64-*"]
  }
}

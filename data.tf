data "terraform_remote_state" "rs_cloudflare" {
  backend = "remote"

  config = {
    hostname     = "redacted.scalr.io"
    organization = var.scalr_environment_id
    workspaces = {
      name = "cloudflare"
    }
  }
}

locals {
  aws_cert_arn       = data.terraform_remote_state.rs_cloudflare.outputs.aws_cert_arn
  cloudflare_cert_id = data.terraform_remote_state.rs_cloudflare.outputs.cloudflare_cert_id
}

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

resource "aws_service_discovery_private_dns_namespace" "prowler" {
  vpc  = data.aws_vpc.main.id
  name = "prowler"
}

resource "aws_service_discovery_service" "prowler_api" {
  name = "prowler-api"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.prowler.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "prowler_ui" {
  name = "prowler-ui"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.prowler.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "prowler_worker" {
  name = "prowler-worker"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.prowler.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "prowler_worker_beat" {
  name = "prowler-worker-beat"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.prowler.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

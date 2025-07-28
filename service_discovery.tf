resource "aws_service_discovery_private_dns_namespace" "service_connect" {
  name        = "prowler-app.local"
  vpc         = data.aws_vpc.main.id
  description = "Service Connect namespace for prowler services"

  tags = merge({
    Name = "prowler-app-service-connect-namespace"
  })
}

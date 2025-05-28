resource "aws_service_discovery_private_dns_namespace" "prowler" {
  vpc  = data.aws_vpc.main.id
  name = "prowler"
}

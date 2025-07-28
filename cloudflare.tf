# provider "cloudflare" {
#   # replace with service account token
#   api_token = "redacted"
# }

# data "cloudflare_zone" "main" {
#   zone_id = local.zone_id
# }

# locals {
#   zone_id = "redacted"
# }

# resource "cloudflare_dns_record" "prowler" {
#   zone_id = data.cloudflare_zone.main.zone_id
#   name    = "prowler.${var.environment}"
#   content = aws_lb.public.dns_name
#   type    = "CNAME"
#   ttl     = 1
#   proxied = true

#   ## Comment this out if you actually need to update cloudflare
#   lifecycle {
#     ignore_changes = all
#   }
# }

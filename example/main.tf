module "prowler" {
  source                        = "../../../modules/scalr/terraform-aws-prowler"
  scalr_environment_id          = var.scalr_environment_id
  app_domain                    = var.app_domain
  environment                   = var.environment
  auth_secret                   = var.auth_secret
  postgres_admin_password       = var.postgres_admin_password
  postgres_password             = var.postgres_password
  django_secrets_encryption_key = var.django_secrets_encryption_key
  django_token_signing_key      = var.django_token_signing_key
  django_token_verifying_key    = var.django_token_verifying_key
  django_allowed_hosts          = var.app_domain
  django_debug                  = "True"
  django_logging_level          = "DEBUG"
}

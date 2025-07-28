module "prowler-ui" {
  source                        = "../../../modules/scalr/POC/prowler-ui"
  environment                   = var.environment
  scalr_environment_id          = var.scalr_environment_id
  ui_domain                     = "prowler.${var.environment}.redacted.cloud"
  postgres_password             = "postgres_password"
  postgres_admin_password       = "postgres_password"
  django_secrets_encryption_key = ""
  auth_secret                   = ""
  django_token_verifying_key    = var.django_token_verifying_key
  django_token_signing_key      = var.django_token_signing_key
  external_id                   = ""
}

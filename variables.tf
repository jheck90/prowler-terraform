variable "app_name" {
  default = "prowler"
  type    = string
}
# Required variables
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "scalr_environment_id" {
  description = "Scalr environment ID for remote state"
  type        = string
}

variable "ui_domain" {
  description = "Domain name for the ui"
  type        = string
}

variable "vpn_cidr" {
  default = ""
  type    = string
}

# API variables
variable "prowler_api_version" {
  description = "Prowler API version"
  type        = string
  default     = "stable_v1.0.0"
}

variable "django_port" {
  description = "Django port"
  type        = number
  default     = 8080
}

variable "django_allowed_hosts" {
  description = "Django allowed hosts"
  type        = string
  default     = "*"
}

variable "django_debug" {
  description = "Django debug mode"
  type        = string
  default     = "false"
}

variable "django_settings_module" {
  description = "Django settings module"
  type        = string
  default     = "config.django.production"
}

variable "django_logging_formatter" {
  description = "Django logging formatter"
  type        = string
  default     = "human_readable"
}

variable "django_logging_level" {
  description = "Django logging level"
  type        = string
  default     = "DEBUG"
}

variable "django_workers" {
  description = "Django workers count"
  type        = number
  default     = 4
}

variable "django_findings_batch_size" {
  description = "Django findings batch size"
  type        = number
  default     = 1000
}

variable "django_access_token_lifetime" {
  description = "Django access token lifetime in minutes"
  type        = number
  default     = 30
}

variable "django_refresh_token_lifetime" {
  description = "Django refresh token lifetime in minutes"
  type        = number
  default     = 1440
}

variable "django_cache_max_age" {
  description = "Django cache max age in seconds"
  type        = number
  default     = 3600
}

variable "django_stale_while_revalidate" {
  description = "Django stale while revalidate in seconds"
  type        = number
  default     = 60
}

variable "django_manage_db_partitions" {
  description = "Django manage DB partitions"
  type        = bool
  default     = true
}

variable "django_broker_visibility_timeout" {
  description = "Django broker visibility timeout"
  type        = number
  default     = 86400
}

# UI variables
variable "prowler_ui_version" {
  description = "Prowler UI version"
  type        = string
  default     = "stable_v1.4.3"
}

variable "ui_port" {
  description = "UI port"
  type        = number
  default     = 3000
}

variable "prowler_release_version" {
  description = "Prowler release version"
  type        = string
  default     = "v5.7.5"
}

# PostgreSQL variables
variable "postgres_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "postgres_admin_user" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "postgres"
}

variable "postgres_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "postgres_user" {
  description = "PostgreSQL application username"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "PostgreSQL application password"
  type        = string
  sensitive   = true
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "prowler_db"
}

# Valkey variables
variable "valkey_port" {
  description = "Valkey port"
  type        = number
  default     = 6379
}

variable "valkey_db" {
  description = "Valkey database index"
  type        = number
  default     = 0
}

# Secret variables
variable "auth_secret" {
  description = "Auth secret for NextAuth"
  type        = string
  sensitive   = true
}

variable "django_token_signing_key" {
  description = "Django token signing key"
  type        = string
  sensitive   = true
}

variable "django_token_verifying_key" {
  description = "Django token verifying key"
  type        = string
  sensitive   = true
}

variable "django_secrets_encryption_key" {
  description = "Django secrets encryption key"
  type        = string
  sensitive   = true
}

# OAuth variables (optional)
variable "google_oauth_client_id" {
  description = "Google OAuth client ID"
  type        = string
  default     = ""
}

variable "google_oauth_client_secret" {
  description = "Google OAuth client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_oauth_client_id" {
  description = "GitHub OAuth client ID"
  type        = string
  default     = ""
}

variable "github_oauth_client_secret" {
  description = "GitHub OAuth client secret"
  type        = string
  default     = ""
  sensitive   = true
}

# S3 bucket for output (optional)
variable "output_s3_bucket" {
  description = "S3 bucket for storing scan outputs"
  type        = string
  default     = ""
}

variable "prowler_instance_type" {
  type    = string
  default = "t3a.medium"
}

variable "prowler_volume_size" {
  type    = number
  default = 40
}

variable "prowler_volume_type" {
  type    = string
  default = "gp3"
}

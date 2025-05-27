# prowler-terraform
A POC for running Prowler in an AWS account.

Relevant Prowler [Docker Compose](https://github.com/prowler-cloud/prowler/blob/master/docker-compose.yml) this is based off of

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.postgres_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.prowler_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.prowler_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.prowler_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.prowler_worker_beat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_instance.postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_ecr_lifecycle_policy.api_untagged_cleanup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_lifecycle_policy.ui_untagged_cleanup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.prowler_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.prowler_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.worker_beat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.worker_beat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_elasticache_parameter_group.valkey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_parameter_group) | resource |
| [aws_elasticache_replication_group.valkey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.valkey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_iam_policy.ecr_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecs_exec_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.secrets_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ui_secrets_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.worker_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.event_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.event_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_ecr_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_exec_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.secrets_access_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ui_secrets_access_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.worker_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb_listener_rule.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_secretsmanager_secret.auth_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.django_secrets_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.django_token_signing_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.django_token_verifying_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.github_oauth_client_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.github_oauth_client_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.google_oauth_client_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.google_oauth_client_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.postgres_admin_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.postgres_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.auth_secret_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.django_secrets_encryption_key_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.django_token_signing_key_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.django_token_verifying_key_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.github_oauth_client_id_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.github_oauth_client_secret_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.google_oauth_client_id_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.google_oauth_client_secret_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.postgres_admin_password_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.postgres_password_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.api_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.postgres_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ui_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.valkey_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.worker_beat_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.worker_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_service_discovery_private_dns_namespace.prowler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_service_discovery_service.prowler_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_service_discovery_service.prowler_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_service_discovery_service.prowler_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_service_discovery_service.prowler_worker_beat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_ssm_parameter.postgres_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.postgres_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.postgres_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.valkey_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.valkey_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ami.linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_lb_listener.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb_listener) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route_tables.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.protected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_domain"></a> [app\_domain](#input\_app\_domain) | Domain name for the application | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | n/a | `string` | `"prowler"` | no |
| <a name="input_auth_secret"></a> [auth\_secret](#input\_auth\_secret) | Auth secret for NextAuth | `string` | n/a | yes |
| <a name="input_django_access_token_lifetime"></a> [django\_access\_token\_lifetime](#input\_django\_access\_token\_lifetime) | Django access token lifetime in minutes | `number` | `30` | no |
| <a name="input_django_allowed_hosts"></a> [django\_allowed\_hosts](#input\_django\_allowed\_hosts) | Django allowed hosts | `string` | `"*"` | no |
| <a name="input_django_broker_visibility_timeout"></a> [django\_broker\_visibility\_timeout](#input\_django\_broker\_visibility\_timeout) | Django broker visibility timeout | `number` | `86400` | no |
| <a name="input_django_cache_max_age"></a> [django\_cache\_max\_age](#input\_django\_cache\_max\_age) | Django cache max age in seconds | `number` | `3600` | no |
| <a name="input_django_debug"></a> [django\_debug](#input\_django\_debug) | Django debug mode | `string` | `"false"` | no |
| <a name="input_django_findings_batch_size"></a> [django\_findings\_batch\_size](#input\_django\_findings\_batch\_size) | Django findings batch size | `number` | `1000` | no |
| <a name="input_django_logging_formatter"></a> [django\_logging\_formatter](#input\_django\_logging\_formatter) | Django logging formatter | `string` | `"human_readable"` | no |
| <a name="input_django_logging_level"></a> [django\_logging\_level](#input\_django\_logging\_level) | Django logging level | `string` | `"INFO"` | no |
| <a name="input_django_manage_db_partitions"></a> [django\_manage\_db\_partitions](#input\_django\_manage\_db\_partitions) | Django manage DB partitions | `bool` | `true` | no |
| <a name="input_django_port"></a> [django\_port](#input\_django\_port) | Django port | `number` | `8080` | no |
| <a name="input_django_refresh_token_lifetime"></a> [django\_refresh\_token\_lifetime](#input\_django\_refresh\_token\_lifetime) | Django refresh token lifetime in minutes | `number` | `1440` | no |
| <a name="input_django_secrets_encryption_key"></a> [django\_secrets\_encryption\_key](#input\_django\_secrets\_encryption\_key) | Django secrets encryption key | `string` | n/a | yes |
| <a name="input_django_settings_module"></a> [django\_settings\_module](#input\_django\_settings\_module) | Django settings module | `string` | `"config.django.production"` | no |
| <a name="input_django_stale_while_revalidate"></a> [django\_stale\_while\_revalidate](#input\_django\_stale\_while\_revalidate) | Django stale while revalidate in seconds | `number` | `60` | no |
| <a name="input_django_token_signing_key"></a> [django\_token\_signing\_key](#input\_django\_token\_signing\_key) | Django token signing key | `string` | n/a | yes |
| <a name="input_django_token_verifying_key"></a> [django\_token\_verifying\_key](#input\_django\_token\_verifying\_key) | Django token verifying key | `string` | n/a | yes |
| <a name="input_django_workers"></a> [django\_workers](#input\_django\_workers) | Django workers count | `number` | `4` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_github_oauth_client_id"></a> [github\_oauth\_client\_id](#input\_github\_oauth\_client\_id) | GitHub OAuth client ID | `string` | `""` | no |
| <a name="input_github_oauth_client_secret"></a> [github\_oauth\_client\_secret](#input\_github\_oauth\_client\_secret) | GitHub OAuth client secret | `string` | `""` | no |
| <a name="input_google_oauth_client_id"></a> [google\_oauth\_client\_id](#input\_google\_oauth\_client\_id) | Google OAuth client ID | `string` | `""` | no |
| <a name="input_google_oauth_client_secret"></a> [google\_oauth\_client\_secret](#input\_google\_oauth\_client\_secret) | Google OAuth client secret | `string` | `""` | no |
| <a name="input_output_s3_bucket"></a> [output\_s3\_bucket](#input\_output\_s3\_bucket) | S3 bucket for storing scan outputs | `string` | `""` | no |
| <a name="input_postgres_admin_password"></a> [postgres\_admin\_password](#input\_postgres\_admin\_password) | PostgreSQL admin password | `string` | n/a | yes |
| <a name="input_postgres_admin_user"></a> [postgres\_admin\_user](#input\_postgres\_admin\_user) | PostgreSQL admin username | `string` | `"prowler_admin"` | no |
| <a name="input_postgres_db"></a> [postgres\_db](#input\_postgres\_db) | PostgreSQL database name | `string` | `"prowler_db"` | no |
| <a name="input_postgres_password"></a> [postgres\_password](#input\_postgres\_password) | PostgreSQL application password | `string` | n/a | yes |
| <a name="input_postgres_port"></a> [postgres\_port](#input\_postgres\_port) | PostgreSQL port | `number` | `5432` | no |
| <a name="input_postgres_user"></a> [postgres\_user](#input\_postgres\_user) | PostgreSQL application username | `string` | `"prowler"` | no |
| <a name="input_prowler_api_version"></a> [prowler\_api\_version](#input\_prowler\_api\_version) | Prowler API version | `string` | `"latest"` | no |
| <a name="input_prowler_instance_type"></a> [prowler\_instance\_type](#input\_prowler\_instance\_type) | n/a | `string` | `"t3a.medium"` | no |
| <a name="input_prowler_release_version"></a> [prowler\_release\_version](#input\_prowler\_release\_version) | Prowler release version | `string` | `"v5.6.0"` | no |
| <a name="input_prowler_ui_version"></a> [prowler\_ui\_version](#input\_prowler\_ui\_version) | Prowler UI version | `string` | `"latest"` | no |
| <a name="input_prowler_volume_size"></a> [prowler\_volume\_size](#input\_prowler\_volume\_size) | n/a | `number` | `40` | no |
| <a name="input_prowler_volume_type"></a> [prowler\_volume\_type](#input\_prowler\_volume\_type) | n/a | `string` | `"gp3"` | no |
| <a name="input_scalr_environment_id"></a> [scalr\_environment\_id](#input\_scalr\_environment\_id) | Scalr environment ID for remote state | `string` | n/a | yes |
| <a name="input_ui_port"></a> [ui\_port](#input\_ui\_port) | UI port | `number` | `3000` | no |
| <a name="input_valkey_db"></a> [valkey\_db](#input\_valkey\_db) | Valkey database index | `number` | `0` | no |
| <a name="input_valkey_port"></a> [valkey\_port](#input\_valkey\_port) | Valkey port | `number` | `6379` | no |
| <a name="input_vpn_cidr"></a> [vpn\_cidr](#input\_vpn\_cidr) | n/a | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repository_urls"></a> [ecr\_repository\_urls](#output\_ecr\_repository\_urls) | URLs of the ECR repositories |
<!-- END_TF_DOCS -->

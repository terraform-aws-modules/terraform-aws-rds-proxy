# RDS Proxy
output "proxy_id" {
  description = "The ID for the proxy"
  value       = try(aws_db_proxy.this[0].id, null)
}

output "proxy_arn" {
  description = "The Amazon Resource Name (ARN) for the proxy"
  value       = try(aws_db_proxy.this[0].arn, null)
}

output "proxy_endpoint" {
  description = "The endpoint that you can use to connect to the proxy"
  value       = try(aws_db_proxy.this[0].endpoint, null)
}

# Proxy Default Target Group
output "proxy_default_target_group_id" {
  description = "The ID for the default target group"
  value       = try(aws_db_proxy_default_target_group.this[0].id, null)
}

output "proxy_default_target_group_arn" {
  description = "The Amazon Resource Name (ARN) for the default target group"
  value       = try(aws_db_proxy_default_target_group.this[0].arn, null)
}

output "proxy_default_target_group_name" {
  description = "The name of the default target group"
  value       = try(aws_db_proxy_default_target_group.this[0].name, null)
}

# Proxy Target
output "proxy_target_endpoint" {
  description = "Hostname for the target RDS DB Instance. Only returned for `RDS_INSTANCE` type"
  value       = try(aws_db_proxy_target.db_instance[0].endpoint, aws_db_proxy_target.db_cluster[0].endpoint, null)
}

output "proxy_target_id" {
  description = "Identifier of `db_proxy_name`, `target_group_name`, target type (e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`), and resource identifier separated by forward slashes (/)"
  value       = try(aws_db_proxy_target.db_instance[0].id, aws_db_proxy_target.db_cluster[0].id, null)
}

output "proxy_target_port" {
  description = "Port for the target RDS DB Instance or Aurora DB Cluster"
  value       = try(aws_db_proxy_target.db_instance[0].port, aws_db_proxy_target.db_cluster[0].port, null)
}

output "proxy_target_rds_resource_id" {
  description = "Identifier representing the DB Instance or DB Cluster target"
  value       = try(aws_db_proxy_target.db_instance[0].rds_resource_id, aws_db_proxy_target.db_cluster[0].rds_resource_id, null)
}

output "proxy_target_target_arn" {
  description = "Amazon Resource Name (ARN) for the DB instance or DB cluster. Currently not returned by the RDS API"
  value       = try(aws_db_proxy_target.db_instance[0].target_arn, aws_db_proxy_target.db_cluster[0].target_arn, null)
}

output "proxy_target_tracked_cluster_id" {
  description = "DB Cluster identifier for the DB Instance target. Not returned unless manually importing an RDS_INSTANCE target that is part of a DB Cluster"
  value       = try(aws_db_proxy_target.db_cluster[0].tracked_cluster_id, null)
}

output "proxy_target_type" {
  description = "Type of target. e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`"
  value       = try(aws_db_proxy_target.db_instance[0].type, aws_db_proxy_target.db_cluster[0].type, null)
}

# DB proxy endpoints
output "db_proxy_endpoints" {
  description = "Array containing the full resource object and attributes for all DB proxy endpoints created"
  value       = aws_db_proxy_endpoint.this
}

# CloudWatch logs
output "log_group_arn" {
  description = "The Amazon Resource Name (ARN) of the CloudWatch log group"
  value       = try(aws_cloudwatch_log_group.this[0].arn, null)
}

# IAM role
output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role that the proxy uses to access secrets in AWS Secrets Manager."
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_role_name" {
  description = "IAM role name"
  value       = try(aws_iam_role.this[0].name, null)
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.this[0].unique_id, null)
}

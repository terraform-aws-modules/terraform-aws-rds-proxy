# RDS Proxy
output "proxy_id" {
  description = "The ID for the proxy"
  value       = module.rds_proxy.proxy_id
}

output "proxy_arn" {
  description = "The Amazon Resource Name (ARN) for the proxy"
  value       = module.rds_proxy.proxy_arn
}

output "proxy_endpoint" {
  description = "The endpoint that you can use to connect to the proxy"
  value       = module.rds_proxy.proxy_endpoint
}

# Proxy Default Target Group
output "proxy_default_target_group_id" {
  description = "The ID for the default target group"
  value       = module.rds_proxy.proxy_default_target_group_id
}

output "proxy_default_target_group_arn" {
  description = "The Amazon Resource Name (ARN) for the default target group"
  value       = module.rds_proxy.proxy_default_target_group_arn
}

output "proxy_default_target_group_name" {
  description = "The name of the default target group"
  value       = module.rds_proxy.proxy_default_target_group_name
}

# Proxy Target
output "proxy_target_endpoint" {
  description = "Hostname for the target RDS DB Instance. Only returned for `RDS_INSTANCE` type"
  value       = module.rds_proxy.proxy_target_endpoint
}

output "proxy_target_id" {
  description = "Identifier of `db_proxy_name`, `target_group_name`, target type (e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`), and resource identifier separated by forward slashes (/)"
  value       = module.rds_proxy.proxy_target_id
}

output "proxy_target_port" {
  description = "Port for the target RDS DB Instance or Aurora DB Cluster"
  value       = module.rds_proxy.proxy_target_port
}

output "proxy_target_rds_resource_id" {
  description = "Identifier representing the DB Instance or DB Cluster target"
  value       = module.rds_proxy.proxy_target_rds_resource_id
}

output "proxy_target_target_arn" {
  description = "Amazon Resource Name (ARN) for the DB instance or DB cluster. Currently not returned by the RDS API"
  value       = module.rds_proxy.proxy_target_target_arn
}

output "proxy_target_tracked_cluster_id" {
  description = "DB Cluster identifier for the DB Instance target. Not returned unless manually importing an RDS_INSTANCE target that is part of a DB Cluster"
  value       = module.rds_proxy.proxy_target_tracked_cluster_id
}

output "proxy_target_type" {
  description = "Type of target. e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`"
  value       = module.rds_proxy.proxy_target_type
}

# DB proxy endponts
output "db_proxy_endpoints" {
  description = "Array containing the full resource object and attributes for all DB proxy endpoints created"
  value       = module.rds_proxy.db_proxy_endpoints
}

# CloudWatch logs
output "log_group_arn" {
  description = "The Amazon Resource Name (ARN) of the CloudWatch log group"
  value       = module.rds_proxy.log_group_arn
}

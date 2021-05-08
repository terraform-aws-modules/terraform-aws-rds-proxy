# RDS Proxy
output "proxy_id" {
  description = "The ID for the proxy"
  value       = element(concat(aws_db_proxy.this.*.id, [""]), 0)
}

output "proxy_arn" {
  description = "The Amazon Resource Name (ARN) for the proxy"
  value       = element(concat(aws_db_proxy.this.*.arn, [""]), 0)
}

output "proxy_endpoint" {
  description = "The endpoint that you can use to connect to the proxy"
  value       = element(concat(aws_db_proxy.this.*.endpoint, [""]), 0)
}

# Proxy Default Target Group
output "proxy_default_target_group_id" {
  description = "The ID for the default target group"
  value       = element(concat(aws_db_proxy_default_target_group.this.*.id, [""]), 0)
}

output "proxy_default_target_group_arn" {
  description = "The Amazon Resource Name (ARN) for the default target group"
  value       = element(concat(aws_db_proxy_default_target_group.this.*.arn, [""]), 0)
}

output "proxy_default_target_group_name" {
  description = "The name of the default target group"
  value       = element(concat(aws_db_proxy_default_target_group.this.*.name, [""]), 0)
}

# Proxy Target
output "proxy_target_endpoint" {
  description = "Hostname for the target RDS DB Instance. Only returned for `RDS_INSTANCE` type"
  value       = element(concat(aws_db_proxy_target.db_instance.*.endpoint, aws_db_proxy_target.db_cluster.*.endpoint, [""]), 0)
}

output "proxy_target_id" {
  description = "Identifier of `db_proxy_name`, `target_group_name`, target type (e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`), and resource identifier separated by forward slashes (/)"
  value       = element(concat(aws_db_proxy_target.db_instance.*.id, aws_db_proxy_target.db_cluster.*.id, [""]), 0)
}

output "proxy_target_port" {
  description = "Port for the target RDS DB Instance or Aurora DB Cluster"
  value       = element(concat(aws_db_proxy_target.db_instance.*.port, aws_db_proxy_target.db_cluster.*.port, [""]), 0)
}

output "proxy_target_rds_resource_id" {
  description = "Identifier representing the DB Instance or DB Cluster target"
  value       = element(concat(aws_db_proxy_target.db_instance.*.rds_resource_id, aws_db_proxy_target.db_cluster.*.rds_resource_id, [""]), 0)
}

output "proxy_target_target_arn" {
  description = "Amazon Resource Name (ARN) for the DB instance or DB cluster. Currently not returned by the RDS API"
  value       = element(concat(aws_db_proxy_target.db_instance.*.target_arn, aws_db_proxy_target.db_cluster.*.target_arn, [""]), 0)
}

output "proxy_target_tracked_cluster_id" {
  description = "DB Cluster identifier for the DB Instance target. Not returned unless manually importing an RDS_INSTANCE target that is part of a DB Cluster"
  value       = element(concat(aws_db_proxy_target.db_cluster.*.tracked_cluster_id, [""]), 0)
}

output "proxy_target_type" {
  description = "Type of target. e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`"
  value       = element(concat(aws_db_proxy_target.db_instance.*.type, aws_db_proxy_target.db_cluster.*.type, [""]), 0)
}

# DB proxy endponts
output "db_proxy_endpoints" {
  description = "Array containing the full resource object and attributes for all DB proxy endpoints created"
  value       = aws_db_proxy_endpoint.this
}

# CloudWatch logs
output "log_group_arn" {
  description = "The Amazon Resource Name (ARN) of the CloudWatch log group"
  value       = element(concat(aws_cloudwatch_log_group.this.*.arn, [""]), 0)
}

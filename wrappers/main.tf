module "wrapper" {
  source = "../"

  for_each = var.items

  auth = try(each.value.auth, var.defaults.auth, {
    default = {
      auth_scheme = "SECRETS"
    }
  })
  connection_borrow_timeout      = try(each.value.connection_borrow_timeout, var.defaults.connection_borrow_timeout, null)
  create                         = try(each.value.create, var.defaults.create, true)
  create_iam_policy              = try(each.value.create_iam_policy, var.defaults.create_iam_policy, true)
  create_iam_role                = try(each.value.create_iam_role, var.defaults.create_iam_role, true)
  db_cluster_identifier          = try(each.value.db_cluster_identifier, var.defaults.db_cluster_identifier, "")
  db_instance_identifier         = try(each.value.db_instance_identifier, var.defaults.db_instance_identifier, "")
  debug_logging                  = try(each.value.debug_logging, var.defaults.debug_logging, false)
  default_auth_scheme            = try(each.value.default_auth_scheme, var.defaults.default_auth_scheme, null)
  endpoints                      = try(each.value.endpoints, var.defaults.endpoints, {})
  engine_family                  = try(each.value.engine_family, var.defaults.engine_family, "")
  iam_policy_name                = try(each.value.iam_policy_name, var.defaults.iam_policy_name, "")
  iam_role_description           = try(each.value.iam_role_description, var.defaults.iam_role_description, "")
  iam_role_force_detach_policies = try(each.value.iam_role_force_detach_policies, var.defaults.iam_role_force_detach_policies, true)
  iam_role_max_session_duration  = try(each.value.iam_role_max_session_duration, var.defaults.iam_role_max_session_duration, 43200)
  iam_role_name                  = try(each.value.iam_role_name, var.defaults.iam_role_name, "")
  iam_role_path                  = try(each.value.iam_role_path, var.defaults.iam_role_path, null)
  iam_role_permissions_boundary  = try(each.value.iam_role_permissions_boundary, var.defaults.iam_role_permissions_boundary, null)
  iam_role_tags                  = try(each.value.iam_role_tags, var.defaults.iam_role_tags, {})
  idle_client_timeout            = try(each.value.idle_client_timeout, var.defaults.idle_client_timeout, 1800)
  init_query                     = try(each.value.init_query, var.defaults.init_query, "")
  kms_key_arns                   = try(each.value.kms_key_arns, var.defaults.kms_key_arns, [])
  log_group_class                = try(each.value.log_group_class, var.defaults.log_group_class, null)
  log_group_kms_key_id           = try(each.value.log_group_kms_key_id, var.defaults.log_group_kms_key_id, null)
  log_group_retention_in_days    = try(each.value.log_group_retention_in_days, var.defaults.log_group_retention_in_days, 30)
  log_group_tags                 = try(each.value.log_group_tags, var.defaults.log_group_tags, {})
  manage_log_group               = try(each.value.manage_log_group, var.defaults.manage_log_group, true)
  max_connections_percent        = try(each.value.max_connections_percent, var.defaults.max_connections_percent, 90)
  max_idle_connections_percent   = try(each.value.max_idle_connections_percent, var.defaults.max_idle_connections_percent, 50)
  name                           = try(each.value.name, var.defaults.name, "")
  proxy_tags                     = try(each.value.proxy_tags, var.defaults.proxy_tags, {})
  region                         = try(each.value.region, var.defaults.region, null)
  require_tls                    = try(each.value.require_tls, var.defaults.require_tls, true)
  role_arn                       = try(each.value.role_arn, var.defaults.role_arn, "")
  session_pinning_filters        = try(each.value.session_pinning_filters, var.defaults.session_pinning_filters, [])
  tags                           = try(each.value.tags, var.defaults.tags, {})
  target_db_cluster              = try(each.value.target_db_cluster, var.defaults.target_db_cluster, false)
  target_db_instance             = try(each.value.target_db_instance, var.defaults.target_db_instance, false)
  use_policy_name_prefix         = try(each.value.use_policy_name_prefix, var.defaults.use_policy_name_prefix, false)
  use_role_name_prefix           = try(each.value.use_role_name_prefix, var.defaults.use_role_name_prefix, false)
  vpc_security_group_ids         = try(each.value.vpc_security_group_ids, var.defaults.vpc_security_group_ids, [])
  vpc_subnet_ids                 = try(each.value.vpc_subnet_ids, var.defaults.vpc_subnet_ids, [])
}

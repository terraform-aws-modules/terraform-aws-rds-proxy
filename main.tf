locals {
  role_arn    = var.create_proxy && var.create_iam_role ? aws_iam_role.this[0].arn : var.role_arn
  role_name   = coalesce(var.iam_role_name, var.name)
  policy_name = coalesce(var.iam_policy_name, var.name)
}

data "aws_region" "current" {}

################################################################################
# RDS Proxy
################################################################################

resource "aws_db_proxy" "this" {
  count = var.create_proxy ? 1 : 0

  name                   = var.name
  debug_logging          = var.debug_logging
  engine_family          = var.engine_family
  idle_client_timeout    = var.idle_client_timeout
  require_tls            = var.require_tls
  role_arn               = local.role_arn
  vpc_security_group_ids = var.vpc_security_group_ids
  vpc_subnet_ids         = var.vpc_subnet_ids

  dynamic "auth" {
    for_each = var.secrets
    content {
      auth_scheme = var.auth_scheme
      description = auth.value.description
      iam_auth    = var.iam_auth
      secret_arn  = auth.value.arn
    }
  }

  tags = merge(var.tags, var.proxy_tags)

  depends_on = [aws_cloudwatch_log_group.this]
}

resource "aws_db_proxy_default_target_group" "this" {
  count = var.create_proxy ? 1 : 0

  db_proxy_name = aws_db_proxy.this[0].name

  connection_pool_config {
    connection_borrow_timeout    = var.connection_borrow_timeout
    init_query                   = var.init_query
    max_connections_percent      = var.max_connections_percent
    max_idle_connections_percent = var.max_idle_connections_percent
    session_pinning_filters      = var.session_pinning_filters
  }
}

resource "aws_db_proxy_target" "db_instance" {
  count = var.create_proxy && var.target_db_instance ? 1 : 0

  db_proxy_name          = aws_db_proxy.this[0].name
  target_group_name      = aws_db_proxy_default_target_group.this[0].name
  db_instance_identifier = var.db_instance_identifier
}

resource "aws_db_proxy_target" "db_cluster" {
  count = var.create_proxy && var.target_db_cluster ? 1 : 0

  db_proxy_name         = aws_db_proxy.this[0].name
  target_group_name     = aws_db_proxy_default_target_group.this[0].name
  db_cluster_identifier = var.db_cluster_identifier
}

resource "aws_db_proxy_endpoint" "this" {
  for_each = { for k, v in var.db_proxy_endpoints : k => v if var.create_proxy }

  db_proxy_name          = aws_db_proxy.this[0].name
  db_proxy_endpoint_name = each.value.name
  vpc_subnet_ids         = each.value.vpc_subnet_ids
  vpc_security_group_ids = lookup(each.value, "vpc_security_group_ids", null)
  target_role            = lookup(each.value, "target_role", null)

  tags = lookup(each.value, "tags", var.tags)
}

################################################################################
# CloudWatch Logs
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_proxy && var.manage_log_group ? 1 : 0

  name              = "/aws/rds/proxy/${var.name}"
  retention_in_days = var.log_group_retention_in_days
  kms_key_id        = var.log_group_kms_key_id

  tags = merge(var.tags, var.log_group_tags)
}

################################################################################
# IAM Role
################################################################################

data "aws_iam_policy_document" "assume_role" {
  count = var.create_proxy && var.create_iam_role ? 1 : 0

  statement {
    sid     = "RDSAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_proxy && var.create_iam_role ? 1 : 0

  name        = var.use_role_name_prefix ? null : local.role_name
  name_prefix = var.use_role_name_prefix ? "${local.role_name}-" : null
  description = var.iam_role_description
  path        = var.iam_role_path

  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration
  permissions_boundary  = var.iam_role_permissions_boundary

  tags = merge(var.tags, var.iam_role_tags)
}

data "aws_iam_policy_document" "this" {
  count = var.create_proxy && var.create_iam_role ? 1 : 0

  statement {
    sid       = "DecryptSecrets"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = distinct([for secret in var.secrets : secret.kms_key_id])
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = [
        "secretsmanager.${data.aws_region.current.name}.amazonaws.com"
      ]
    }
  }

  statement {
    sid    = "ListSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetRandomPassword",
      "secretsmanager:ListSecrets",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "GetSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]

    resources = distinct([for secret in var.secrets : secret.arn])
  }
}

resource "aws_iam_role_policy" "this" {
  count = var.create_proxy && var.create_iam_role && var.create_iam_policy ? 1 : 0

  name        = var.use_policy_name_prefix ? null : local.policy_name
  name_prefix = var.use_policy_name_prefix ? "${local.policy_name}-" : null
  policy      = data.aws_iam_policy_document.this[0].json
  role        = aws_iam_role.this[0].id
}

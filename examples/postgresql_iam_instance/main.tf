provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
  name   = "rds-proxy-ex-${replace(basename(path.cwd), "_", "-")}"

  db_username = random_pet.users.id # using random here due to secrets taking at least 7 days before fully deleting from account
  db_password = random_password.password.result

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-rds-proxy"
  }
}

################################################################################
# RDS Proxy
################################################################################

module "rds_proxy" {
  source = "../../"

  create_proxy = true

  name                   = local.name
  iam_role_name          = local.name
  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.rds_proxy_sg.security_group_id]

  db_proxy_endpoints = {
    read_write = {
      name                   = "read-write-endpoint"
      vpc_subnet_ids         = module.vpc.private_subnets
      vpc_security_group_ids = [module.rds_proxy_sg.security_group_id]
      tags                   = local.tags
    },
    read_only = {
      name                   = "read-only-endpoint"
      vpc_subnet_ids         = module.vpc.private_subnets
      vpc_security_group_ids = [module.rds_proxy_sg.security_group_id]
      target_role            = "READ_ONLY"
      tags                   = local.tags
    }
  }

  secrets = {
    (local.db_username) = {
      description = aws_secretsmanager_secret.superuser.description
      arn         = aws_secretsmanager_secret.superuser.arn
      kms_key_id  = aws_secretsmanager_secret.superuser.kms_key_id
    }
  }

  engine_family = "POSTGRESQL"
  debug_logging = true

  # Target RDS instance
  target_db_instance     = true
  db_instance_identifier = module.rds.db_instance_id

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

resource "random_pet" "users" {
  length    = 2
  separator = "_"
}

resource "random_password" "password" {
  length  = 16
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.0.0.0/18"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  database_subnets = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]

  create_database_subnet_group = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  map_public_ip_on_launch      = false

  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  enable_flow_log                      = true
  flow_log_destination_type            = "cloud-watch-logs"
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
  flow_log_log_format                  = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id}"

  tags = local.tags
}

module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "rds"
  description = "PostgreSQL RDS example security group"
  vpc_id      = module.vpc.vpc_id

  revoke_rules_on_delete = true

  ingress_with_cidr_blocks = [
    {
      description = "Private subnet PostgreSQL access"
      rule        = "postgresql-tcp"
      cidr_blocks = join(",", module.vpc.private_subnets_cidr_blocks)
    }
  ]

  tags = local.tags
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  name     = "example"
  username = local.db_username
  password = local.db_password

  # When using RDS Proxy w/ IAM auth - Database must be username/password auth, not IAM
  iam_database_authentication_enabled = false

  identifier           = local.name
  engine               = "postgres"
  engine_version       = "11.12"
  family               = "postgres11"
  major_engine_version = "11"
  port                 = 5432
  instance_class       = "db.t3.micro"
  allocated_storage    = 5
  storage_encrypted    = true
  apply_immediately    = true

  enabled_cloudwatch_logs_exports = ["postgresql"]
  monitoring_interval             = 60
  create_monitoring_role          = true

  vpc_security_group_ids = [module.rds_sg.security_group_id]
  subnet_ids             = module.vpc.database_subnets
  multi_az               = true

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0
  deletion_protection     = false

  tags = local.tags
}

module "rds_proxy_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "rds_proxy"
  description = "PostgreSQL RDS Proxy example security group"
  vpc_id      = module.vpc.vpc_id

  revoke_rules_on_delete = true

  ingress_with_cidr_blocks = [
    {
      description = "Private subnet PostgreSQL access"
      rule        = "postgresql-tcp"
      cidr_blocks = join(",", module.vpc.private_subnets_cidr_blocks)
    }
  ]

  egress_with_cidr_blocks = [
    {
      description = "Database subnet PostgreSQL access"
      rule        = "postgresql-tcp"
      cidr_blocks = join(",", module.vpc.database_subnets_cidr_blocks)
    },
  ]

  tags = local.tags
}

################################################################################
# Secrets - DB user passwords
################################################################################

data "aws_kms_alias" "secretsmanager" {
  name = "alias/aws/secretsmanager"
}

resource "aws_secretsmanager_secret" "superuser" {
  name        = local.db_username
  description = "Database superuser, ${local.db_username}, databse connection values"
  kms_key_id  = data.aws_kms_alias.secretsmanager.id

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "superuser" {
  secret_id = aws_secretsmanager_secret.superuser.id
  secret_string = jsonencode({
    username = local.db_username
    password = local.db_password
  })
}

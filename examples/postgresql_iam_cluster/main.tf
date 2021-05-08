provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
  name   = "example-${replace(basename(path.cwd), "_", "-")}"

  db_name               = "example"
  db_username           = random_pet.users.id # using random here due to secrets taking at least 7 days before fully deleting from account
  db_password           = random_password.password.result
  db_proxy_resource_id  = element(split(":", module.rds_proxy.proxy_arn), 6)
  db_iam_connect_prefix = "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${local.db_proxy_resource_id}"

  tags = {
    Example     = local.name
    Environment = "dev"
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

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
  version = "~> 3"

  name = local.name
  cidr = "10.0.0.0/18"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  database_subnets = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]

  create_database_subnet_group = true
  enable_nat_gateway           = true
  single_nat_gateway           = true

  tags = local.tags
}

module "rds" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 5"

  name          = local.name
  database_name = local.db_name
  username      = local.db_username
  password      = local.db_password

  # When using RDS Proxy w/ IAM auth - Database must be username/password auth, not IAM
  iam_database_authentication_enabled = false

  engine              = "aurora-postgresql"
  engine_version      = "11.9"
  replica_count       = 1
  instance_type       = "db.t3.medium"
  storage_encrypted   = false
  apply_immediately   = true
  skip_final_snapshot = true

  vpc_id                  = module.vpc.vpc_id
  subnets                 = module.vpc.database_subnets
  allowed_security_groups = [module.rds_proxy_sg.security_group_id]

  db_subnet_group_name            = local.name # Created by VPC module
  db_parameter_group_name         = aws_db_parameter_group.aurora_db_postgres11_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_postgres11_parameter_group.id

  tags = local.tags
}

resource "aws_db_parameter_group" "aurora_db_postgres11_parameter_group" {
  name        = "example-aurora-db-postgres11-parameter-group"
  family      = "aurora-postgresql11"
  description = "test-aurora-db-postgres11-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_postgres11_parameter_group" {
  name        = "example-aurora-postgres11-cluster-parameter-group"
  family      = "aurora-postgresql11"
  description = "example-aurora-postgres11-cluster-parameter-group"
}

################################################################################
# Test Resources
################################################################################

resource "aws_iam_instance_profile" "ec2_test" {
  name_prefix = local.name
  role        = aws_iam_role.ec2_test.name
}

data "aws_iam_policy_document" "ec2_test_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_test" {
  name_prefix           = local.name
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.ec2_test_assume.json
}

data "aws_iam_policy_document" "ec2_test" {
  statement {
    actions   = ["rds-db:connect"]
    resources = ["${local.db_iam_connect_prefix}/${local.db_username}"]
  }
}

resource "aws_iam_role_policy" "ec2_test" {
  name_prefix = local.name
  role        = aws_iam_role.ec2_test.id
  policy      = data.aws_iam_policy_document.ec2_test.json
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_test.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-focal-20.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = "ec2"
  description = "EC2 RDS Proxy example security group"
  vpc_id      = module.vpc.vpc_id

  egress_rules = ["all-all"]

  tags = local.tags
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2"

  name           = local.name
  instance_count = 1

  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_test.name
  user_data                   = <<-EOT
  #!/usr/bin/env bash

  mkdir -p /home/ssm-user/ && wget -O /home/ssm-user/AmazonRootCA1.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem

  apt update
  apt install awscli postgresql-client -y

  EOT

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [module.ec2_sg.security_group_id]
  subnet_ids             = module.vpc.private_subnets

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

################################################################################
# RDS Proxy
################################################################################

module "rds_proxy_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

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
    "${local.db_username}" = {
      description = aws_secretsmanager_secret.superuser.description
      arn         = aws_secretsmanager_secret.superuser.arn
      kms_key_id  = aws_secretsmanager_secret.superuser.kms_key_id
    }
  }

  engine_family = "POSTGRESQL"
  db_host       = module.rds.rds_cluster_endpoint
  db_name       = module.rds.rds_cluster_database_name
  debug_logging = true

  # Target Aurora cluster
  target_db_cluster     = true
  db_cluster_identifier = module.rds.rds_cluster_id

  tags = local.tags
}

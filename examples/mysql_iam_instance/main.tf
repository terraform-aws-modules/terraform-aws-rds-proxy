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
  version = "2.64.0"

  name = local.name
  cidr = "10.0.0.0/18"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  database_subnets = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}

module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"

  name        = "rds"
  description = "MySQL RDS example security group"
  vpc_id      = module.vpc.vpc_id

  revoke_rules_on_delete = true

  ingress_with_cidr_blocks = [
    {
      description = "Private subnet MySQL access"
      rule        = "mysql-tcp"
      cidr_blocks = join(",", module.vpc.private_subnets_cidr_blocks)
    }
  ]

  tags = local.tags
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.20.0"

  name     = local.db_name
  username = local.db_username
  password = local.db_password

  # When using RDS Proxy w/ IAM auth - Database must be username/password auth, not IAM
  iam_database_authentication_enabled = false

  identifier           = local.name
  engine               = "mysql"
  engine_version       = "5.7.31"
  family               = "mysql5.7"
  major_engine_version = "5.7"
  port                 = 3306
  instance_class       = "db.t3.micro"
  allocated_storage    = 5
  storage_encrypted    = false
  apply_immediately    = true

  vpc_security_group_ids = [module.rds_sg.this_security_group_id]
  subnet_ids             = module.vpc.database_subnets

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0
  deletion_protection     = false

  tags = local.tags
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
  version = "3.17.0"

  name        = "ec2"
  description = "EC2 RDS Proxy example security group"
  vpc_id      = module.vpc.vpc_id

  egress_rules = ["all-all"]

  tags = local.tags
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.16.0"

  name           = local.name
  instance_count = 1

  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_test.name
  user_data                   = <<-EOT
  #!/usr/bin/env bash

  mkdir -p /home/ssm-user/ && wget -O /home/ssm-user/AmazonRootCA1.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem

  apt update
  apt install awscli mysql-server -y

  EOT

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [module.ec2_sg.this_security_group_id]
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
  version = "3.17.0"

  name        = "rds_proxy"
  description = "MySQL RDS Proxy example security group"
  vpc_id      = module.vpc.vpc_id

  revoke_rules_on_delete = true

  ingress_with_cidr_blocks = [
    {
      description = "Private subnet PostgreSQL access"
      rule        = "mysql-tcp"
      cidr_blocks = join(",", module.vpc.private_subnets_cidr_blocks)
    }
  ]

  egress_with_cidr_blocks = [
    {
      description = "Database subnet MySQL access"
      rule        = "mysql-tcp"
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
  vpc_security_group_ids = [module.rds_proxy_sg.this_security_group_id]

  secrets = {
    "${local.db_username}" = {
      description = aws_secretsmanager_secret.superuser.description
      arn         = aws_secretsmanager_secret.superuser.arn
      kms_key_id  = aws_secretsmanager_secret.superuser.kms_key_id
    }
  }

  engine_family = "MYSQL"
  db_host       = module.rds.this_db_instance_address
  db_name       = module.rds.this_db_instance_name
  debug_logging = true

  # Target RDS instance
  target_db_instance     = true
  db_instance_identifier = module.rds.this_db_instance_id

  tags = local.tags
}

# RDS Proxy - IAM Authentication & PostgreSQL Cluster

Configuration in this directory creates:

- AWS RDS Proxy w/ IAM authentication enabled for an RDS Aurora PostgreSQL cluster

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

## Validation

An EC2 instance configuration has been provided for use in validating the example configuration. After provisioning the configuration, there are some outputs that have been provided to aid in validating changes. To perform validation, after the EC2 instance finishes provisioning:

1. Connect to the EC2 instance using Session Manager
2. Copy the output from `superuser_proxy_iam_token` and paste it into the Session Manager window - this generates the token for connecting to the proxy with IAM auth.
3. Copy the output from `superuser_proxy_iam_connect` and paste it into the window - NOTE: remove the string escape slashes `psql \"host...` -> `psql "host...`
4. You should now be connected to the `example` database in the RDS instance via the AWS Proxy using IAM authentication

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.26 |
| aws | >= 3.9 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.9 |
| random | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| ec2_instance | terraform-aws-modules/ec2-instance/aws | 2.16.0 |
| ec2_sg | terraform-aws-modules/security-group/aws | 3.17.0 |
| rds | terraform-aws-modules/rds-aurora/aws | 3.0.0 |
| rds_proxy | ../../ |  |
| rds_proxy_sg | terraform-aws-modules/security-group/aws | 3.17.0 |
| vpc | terraform-aws-modules/vpc/aws | 2.64.0 |

## Resources

| Name |
|------|
| [aws_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) |
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_db_parameter_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) |
| [aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |
| [aws_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) |
| [aws_rds_cluster_parameter_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |
| [aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) |
| [aws_secretsmanager_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) |
| [random_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) |
| [random_pet](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) |

## Inputs

No input.

## Outputs

| Name | Description |
|------|-------------|
| log\_group\_arn | The Amazon Resource Name (ARN) of the CloudWatch log group |
| proxy\_arn | The Amazon Resource Name (ARN) for the proxy |
| proxy\_default\_target\_group\_arn | The Amazon Resource Name (ARN) for the default target group |
| proxy\_default\_target\_group\_id | The ID for the default target group |
| proxy\_default\_target\_group\_name | The name of the default target group |
| proxy\_endpoint | The endpoint that you can use to connect to the proxy |
| proxy\_id | The ID for the proxy |
| proxy\_target\_endpoint | Hostname for the target RDS DB Instance. Only returned for `RDS_INSTANCE` type |
| proxy\_target\_id | Identifier of `db_proxy_name`, `target_group_name`, target type (e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`), and resource identifier separated by forward slashes (/) |
| proxy\_target\_port | Port for the target RDS DB Instance or Aurora DB Cluster |
| proxy\_target\_rds\_resource\_id | Identifier representing the DB Instance or DB Cluster target |
| proxy\_target\_target\_arn | Amazon Resource Name (ARN) for the DB instance or DB cluster. Currently not returned by the RDS API |
| proxy\_target\_tracked\_cluster\_id | DB Cluster identifier for the DB Instance target. Not returned unless manually importing an RDS\_INSTANCE target that is part of a DB Cluster |
| proxy\_target\_type | Type of target. e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER` |
| superuser\_db\_password\_connect | Connect to database using superuser with username/password directly to database |
| superuser\_proxy\_iam\_connect | Connect to RDS Proxy using IAM auth via token generated |
| superuser\_proxy\_iam\_token | Gerate connection token for connecting to RDS Proxy with IAM auth |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Apache-2.0 Licensed. See [LICENSE](../../LICENSE).

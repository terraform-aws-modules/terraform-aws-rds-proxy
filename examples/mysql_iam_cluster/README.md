# RDS Proxy - IAM Authentication & MySQL Cluster

Configuration in this directory creates:

- AWS RDS Proxy w/ IAM authentication enabled for an RDS Aurora MySQL cluster

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
3. Copy the output from `superuser_proxy_iam_connect` and paste it into the window
4. You should now be connected to the `example` database in the RDS instance via the AWS Proxy using IAM authentication

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.9 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_instance"></a> [ec2\_instance](#module\_ec2\_instance) | terraform-aws-modules/ec2-instance/aws | 2.16.0 |
| <a name="module_ec2_sg"></a> [ec2\_sg](#module\_ec2\_sg) | terraform-aws-modules/security-group/aws | 3.17.0 |
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds-aurora/aws | 3.0.0 |
| <a name="module_rds_proxy"></a> [rds\_proxy](#module\_rds\_proxy) | ../../ |  |
| <a name="module_rds_proxy_sg"></a> [rds\_proxy\_sg](#module\_rds\_proxy\_sg) | terraform-aws-modules/security-group/aws | 3.17.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 2.64.0 |

## Resources

| Name | Type |
|------|------|
| [aws_db_parameter_group.aurora_db_mysql57_parameter_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_iam_instance_profile.ec2_test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2_test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ec2_test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ec2_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_rds_cluster_parameter_group.aurora_cluster_mysql57_parameter_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) | resource |
| [aws_secretsmanager_secret.superuser](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.superuser](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_pet.users](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ec2_test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ec2_test_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_alias.secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | The Amazon Resource Name (ARN) of the CloudWatch log group |
| <a name="output_proxy_arn"></a> [proxy\_arn](#output\_proxy\_arn) | The Amazon Resource Name (ARN) for the proxy |
| <a name="output_proxy_default_target_group_arn"></a> [proxy\_default\_target\_group\_arn](#output\_proxy\_default\_target\_group\_arn) | The Amazon Resource Name (ARN) for the default target group |
| <a name="output_proxy_default_target_group_id"></a> [proxy\_default\_target\_group\_id](#output\_proxy\_default\_target\_group\_id) | The ID for the default target group |
| <a name="output_proxy_default_target_group_name"></a> [proxy\_default\_target\_group\_name](#output\_proxy\_default\_target\_group\_name) | The name of the default target group |
| <a name="output_proxy_endpoint"></a> [proxy\_endpoint](#output\_proxy\_endpoint) | The endpoint that you can use to connect to the proxy |
| <a name="output_proxy_id"></a> [proxy\_id](#output\_proxy\_id) | The ID for the proxy |
| <a name="output_proxy_target_endpoint"></a> [proxy\_target\_endpoint](#output\_proxy\_target\_endpoint) | Hostname for the target RDS DB Instance. Only returned for `RDS_INSTANCE` type |
| <a name="output_proxy_target_id"></a> [proxy\_target\_id](#output\_proxy\_target\_id) | Identifier of `db_proxy_name`, `target_group_name`, target type (e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`), and resource identifier separated by forward slashes (/) |
| <a name="output_proxy_target_port"></a> [proxy\_target\_port](#output\_proxy\_target\_port) | Port for the target RDS DB Instance or Aurora DB Cluster |
| <a name="output_proxy_target_rds_resource_id"></a> [proxy\_target\_rds\_resource\_id](#output\_proxy\_target\_rds\_resource\_id) | Identifier representing the DB Instance or DB Cluster target |
| <a name="output_proxy_target_target_arn"></a> [proxy\_target\_target\_arn](#output\_proxy\_target\_target\_arn) | Amazon Resource Name (ARN) for the DB instance or DB cluster. Currently not returned by the RDS API |
| <a name="output_proxy_target_tracked_cluster_id"></a> [proxy\_target\_tracked\_cluster\_id](#output\_proxy\_target\_tracked\_cluster\_id) | DB Cluster identifier for the DB Instance target. Not returned unless manually importing an RDS\_INSTANCE target that is part of a DB Cluster |
| <a name="output_proxy_target_type"></a> [proxy\_target\_type](#output\_proxy\_target\_type) | Type of target. e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER` |
| <a name="output_superuser_db_password_connect"></a> [superuser\_db\_password\_connect](#output\_superuser\_db\_password\_connect) | Connect to database using superuser with username/password directly to database |
| <a name="output_superuser_proxy_iam_connect"></a> [superuser\_proxy\_iam\_connect](#output\_superuser\_proxy\_iam\_connect) | Connect to RDS Proxy using IAM auth via token generated |
| <a name="output_superuser_proxy_iam_token"></a> [superuser\_proxy\_iam\_token](#output\_superuser\_proxy\_iam\_token) | Gerate connection token for connecting to RDS Proxy with IAM auth |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Apache-2.0 Licensed. See [LICENSE](../../LICENSE).

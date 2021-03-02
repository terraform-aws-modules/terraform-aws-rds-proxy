# AWS RDS Proxy Terraform module

Terraform module which creates an AWS RDS Proxy and its supporting resources.

The following resources are supported:

- [AWS RDS Proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy)
- [AWS RDS Proxy Default Target Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_default_target_group)
- [AWS RDS Proxy Target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_target)

## Usage

See [`examples`](./examples) directory for working examples to reference:

```hcl
module "rds_proxy" {
  source = "clowdhaus/rds-proxy/aws"

  name                   = "rds-proxy"
  iam_role_name          = "rds-proxy-role"
  vpc_subnet_ids         = ["subnet-30ef7b3c", "subnet-1ecda77b", "subnet-ca09ddbc"]
  vpc_security_group_ids = ["sg-f1d03a88"]

  secrets = {
    "superuser" = {
      description = "Aurora PostgreSQL superuser password"
      arn         = "arn:aws:secretsmanager:us-east-1:123456789012:secret:superuser-6gsjLD"
      kms_key_id  = "6ca29066-552a-46c5-a7d7-7bf9a15fc255"
    }
  }

  engine_family = "POSTGRESQL"
  db_host       = "myendpoint.cluster-custom-123456789012.us-east-1.rds.amazonaws.com"
  db_name       = "example"

  # Target Aurora cluster
  target_db_cluster     = true
  db_cluster_identifier = "myendpoint"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

## Examples

Examples codified under the [`examples`](./examples) are intended to give users references for how to use the module(s) as well as testing/validating changes to the source code of the module(s). If contributing to the project, please be sure to make any appropriate updates to the relevant examples to allow maintainers to test your changes and to keep the examples up to date for users. Thank you!

- [IAM auth. w/ MySQL Aurora cluster](./examples/mysql_iam_cluster)
- [IAM auth. w/ MySQL RDS instance](./examples/mysql_iam_instance)
- [IAM auth. w/ PostgreSQL Aurora cluster](./examples/postgresql_iam_cluster)
- [IAM auth. w/ PostgreSQL RDS instance](./examples/postgresql_iam_instance)

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

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) |
| [aws_db_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy) |
| [aws_db_proxy_default_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_default_target_group) |
| [aws_db_proxy_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_target) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| auth | Configuration block(s) with authorization mechanisms to connect to the associated instances or clusters | `map(string)` | `{}` | no |
| auth\_scheme | The type of authentication that the proxy uses for connections from the proxy to the underlying database. One of `SECRETS` | `string` | `"SECRETS"` | no |
| connection\_borrow\_timeout | The number of seconds for a proxy to wait for a connection to become available in the connection pool | `number` | `null` | no |
| create\_iam\_policy | Determines whether an IAM policy is created | `bool` | `true` | no |
| create\_iam\_role | Determines whether an IAM role is created | `bool` | `true` | no |
| create\_proxy | Determines whether a proxy and its resources will be created | `bool` | `true` | no |
| db\_cluster\_identifier | DB cluster identifier | `string` | `""` | no |
| db\_host | The identifier to use for the database endpoint | `string` | `""` | no |
| db\_instance\_identifier | DB instance identifier | `string` | `""` | no |
| db\_name | The name of the database | `string` | `""` | no |
| debug\_logging | Whether the proxy includes detailed information about SQL statements in its logs | `bool` | `false` | no |
| engine\_family | The kind of database engine that the proxy will connect to. Valid values are `MYSQL` or `POSTGRESQL` | `string` | `""` | no |
| iam\_auth | Whether to require or disallow AWS Identity and Access Management (IAM) authentication for connections to the proxy. One of `DISABLED`, `REQUIRED` | `string` | `"REQUIRED"` | no |
| iam\_creation\_wait\_duration | Time duration delay to wait for IAM resource creation/propagation. For example, 30s for 30 seconds or 5m for 5 minutes. Updating this value by itself will not trigger a delay. | `string` | `"30s"` | no |
| iam\_policy\_name | The name of the role policy. If omitted, Terraform will assign a random, unique name | `string` | `""` | no |
| iam\_role\_description | The description of the role | `string` | `""` | no |
| iam\_role\_force\_detach\_policies | Specifies to force detaching any policies the role has before destroying it | `bool` | `true` | no |
| iam\_role\_max\_session\_duration | The maximum session duration (in seconds) that you want to set for the specified role | `number` | `43200` | no |
| iam\_role\_name | The name of the role. If omitted, Terraform will assign a random, unique name | `string` | `""` | no |
| iam\_role\_path | The path to the role | `string` | `null` | no |
| iam\_role\_permissions\_boundary | The ARN of the policy that is used to set the permissions boundary for the role | `string` | `null` | no |
| iam\_role\_tags | A map of tags to apply to the IAM role | `map(string)` | `{}` | no |
| idle\_client\_timeout | The number of seconds that a connection to the proxy can be inactive before the proxy disconnects it | `number` | `1800` | no |
| init\_query | One or more SQL statements for the proxy to run when opening each new database connection | `string` | `""` | no |
| log\_group\_kms\_key\_id | The ARN of the KMS Key to use when encrypting log data | `string` | `null` | no |
| log\_group\_retention\_in\_days | Specifies the number of days you want to retain log events in the log group | `number` | `30` | no |
| log\_group\_tags | A map of tags to apply to the CloudWatch log group | `map(string)` | `{}` | no |
| manage\_log\_group | Determines whether Terraform will create/manage the CloudWatch log group or not. Note - this will fail if set to true after the log group has been created as the resource will already exist | `bool` | `true` | no |
| max\_connections\_percent | The maximum size of the connection pool for each target in a target group | `number` | `90` | no |
| max\_idle\_connections\_percent | Controls how actively the proxy closes idle database connections in the connection pool | `number` | `50` | no |
| name | The identifier for the proxy. This name must be unique for all proxies owned by your AWS account in the specified AWS Region. An identifier must begin with a letter and must contain only ASCII letters, digits, and hyphens; it can't end with a hyphen or contain two consecutive hyphens | `string` | `""` | no |
| proxy\_tags | A map of tags to apply to the RDS Proxy | `map(string)` | `{}` | no |
| require\_tls | A Boolean parameter that specifies whether Transport Layer Security (TLS) encryption is required for connections to the proxy | `bool` | `true` | no |
| role\_arn | The Amazon Resource Name (ARN) of the IAM role that the proxy uses to access secrets in AWS Secrets Manager | `string` | `""` | no |
| secrets | Map of secerets to be used by RDS Proxy for authentication to the database | `map(object({ arn = string, description = string, kms_key_id = string }))` | `{}` | no |
| session\_pinning\_filters | Each item in the list represents a class of SQL operations that normally cause all later statements in a session using a proxy to be pinned to the same underlying database connection | `list(string)` | `[]` | no |
| tags | A map of tags to use on all resources | `map(string)` | `{}` | no |
| target\_db\_cluster | Determines whether DB cluster is targetted by proxy | `bool` | `false` | no |
| target\_db\_instance | Determines whether DB instance is targetted by proxy | `bool` | `false` | no |
| use\_policy\_name\_prefix | Whether to use unique name beginning with the specified `iam_policy_name` | `bool` | `false` | no |
| use\_role\_name\_prefix | Whether to use unique name beginning with the specified `iam_role_name` | `bool` | `false` | no |
| vpc\_security\_group\_ids | One or more VPC security group IDs to associate with the new proxy | `list(string)` | `[]` | no |
| vpc\_subnet\_ids | One or more VPC subnet IDs to associate with the new proxy | `list(string)` | `[]` | no |

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
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache-2.0 Licensed. See [LICENSE](LICENSE).

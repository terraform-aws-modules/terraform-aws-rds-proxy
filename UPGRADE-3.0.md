# Upgrade from v2.x to v3.x

If you have any questions regarding this upgrade process, please consult the `examples` directory.
If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Minimum supported Terraform version is now 1.0
- Minimum supported AWS provider version is now 5.0
- The manner in which authentication is configured has changed - previously auth settings were provided under `secrets` in conjunction with `auth_scheme` and `iam_auth` variables. Now, auth settings are provided under the `auth` variable for multiple auth entries.

### Variable and output changes

1. Removed variables:

    - `auth_scheme` is now set under the `auth` variable for a given auth entry
    - `iam_auth` is now set under the `auth` variable for a given auth entry

2. Renamed variables:

    - `create_proxy` -> `create`
    - `secrets` -> `auth`
    - `db_proxy_endpoints` -> `endpoints`

3. Added variables:

    - `kms_key_arns` - list of KMS key ARNs to use allowing permission to decrypt SecretsManager secrets

4. Removed outputs:

    - None

5. Renamed outputs:

    - None

6. Added outputs:

    - None

## Diff of Before (v2.x) vs After (v3.x)

```diff
module "rds_proxy" {
  source  = "terraform-aws-modules/rds-proxy/aws"
-  version = "~> 2.0"
+  version = "~> 3.0"

  # Only the affected attributes are shown
-  create_proxy = true
+  create       = true

-  db_proxy_endpoints = {
-  ...
-  }
+  endpoints = {
+    ...
+  }

-  secrets = {
-    "superuser" = {
-      description = "Aurora PostgreSQL superuser password"
-      arn         = "arn:aws:secretsmanager:eu-west-1:123456789012:secret:superuser-6gsjLD"
-      kms_key_id  = "6ca29066-552a-46c5-a7d7-7bf9a15fc255"
-    }
-  }
+  auth = {
+    "superuser" = {
+      description = "Aurora PostgreSQL superuser password"
+      secret_arn  = "arn:aws:secretsmanager:us-east-1:123456789012:secret:superuser-6gsjLD"
+    }
+  }
+  kms_key_arns = ["arn:aws:kms:eu-west-1:123456789012:key/6ca29066-552a-46c5-a7d7-7bf9a15fc255"]
}
```

### State Changes

- None

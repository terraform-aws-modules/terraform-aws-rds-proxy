# Changelog

All notable changes to this project will be documented in this file.

## [4.1.0](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/compare/v4.0.0...v4.1.0) (2025-10-01)


### Features

* Add Terragrunt wrappers ([#38](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/issues/38)) ([33b43c7](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/commit/33b43c72abdad0b01655238d844e56dabca5e6d4))

## [4.0.0](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/compare/v3.2.1...v4.0.0) (2025-09-16)


### ⚠ BREAKING CHANGES

* Upgrade AWS provider and min required Terraform version to `6.0` and `1.5.7` respectively (#34)

### Features

* Upgrade AWS provider and min required Terraform version to `6.0` and `1.5.7` respectively ([#34](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/issues/34)) ([47c0fca](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/commit/47c0fcad4b3e40ef112544028dba1a4c10ee50dc))

## [3.2.1](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/compare/v3.2.0...v3.2.1) (2025-05-22)


### Bug Fixes

* Correct service principal to rds.amazonaws.com (incl China) ([#32](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/issues/32)) ([bbbf50c](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/commit/bbbf50ce8734f05d4ac69fa41c23c88094b82356))

## [3.2.0](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/compare/v3.1.1...v3.2.0) (2024-11-19)


### Features

* Add CloudWatch log group name to outputs ([#28](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/issues/28)) ([0fc0e19](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/commit/0fc0e19e642a2fdcd8f546bf219f78b5db252c65))


### Bug Fixes

* Update CI workflow versions to latest ([#27](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/issues/27)) ([b6f22be](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/commit/b6f22becf63614f365e72a81151c1955ab0d4df3))

## [3.1.1](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/compare/v3.1.0...v3.1.1) (2024-03-06)


### Bug Fixes

* Update CI workflow versions to remove deprecated runtime warnings ([#26](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/issues/26)) ([a31a810](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/commit/a31a81097b9828776e91864973783d0e9530e12d))

## [3.1.0](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/compare/v3.0.0...v3.1.0) (2023-08-30)


### Features

* Add IAM role output ([#22](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/issues/22)) ([d18ae45](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/commit/d18ae45d9ebf8253f7144e6bdc6ef39af9a4863f))

## [3.0.0](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/compare/v2.1.2...v3.0.0) (2023-06-09)


### ⚠ BREAKING CHANGES

* Increase Terraform and AWS provider minimum supported versions; update `auth` configuration schema (#17)

### Features

* Increase Terraform and AWS provider minimum supported versions; update `auth` configuration schema ([#17](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/issues/17)) ([cc39e9d](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/commit/cc39e9d0295495574c406acfed9e288fb6d5df3c))

### [2.1.2](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/compare/v2.1.1...v2.1.2) (2022-10-27)


### Bug Fixes

* Update CI configuration files to use latest version ([#13](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/issues/13)) ([2e11175](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/commit/2e111751a3b6d6a28ac3c7bf8924ac5dcf07e10e))

### [2.1.1](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/compare/v2.1.0...v2.1.1) (2022-08-10)


### Bug Fixes

* Disable endpoint creation when setting `create_proxy = false` ([#12](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/issues/12)) ([26724ab](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/commit/26724abef985c1669d223ff4e12e43cfd35c529a))
* Update documentation to remove prior notice and deprecated workflow ([#9](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/issues/9)) ([8c1720c](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy/commit/8c1720cee3a1402a2114c46990061672befcd6b9))

## [2.1.0](https://github.com/clowdhaus/terraform-aws-rds-proxy/compare/v2.0.1...v2.1.0) (2022-04-20)


### Features

* Repo has moved to [terraform-aws-modules](https://github.com/terraform-aws-modules/terraform-aws-rds-proxy) organization ([ec9c760](https://github.com/clowdhaus/terraform-aws-rds-proxy/commit/ec9c76000eb6a2df12759fbfdd1a44c0207cd6b4))

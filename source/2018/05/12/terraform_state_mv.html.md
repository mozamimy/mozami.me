---
title: Terraform の state mv を使ってべた書きしたリソースをモジュールに移す tips
date: 2018-05-12
tags: infra
---

## :open_file_folder: Terraform におけるファイル分割

codenize ツールとしてポピュラーな [Terraform](https://www.terraform.io/) をミニマルに使いはじめる場合、最初から細かくファイルを分割するのではなく、たとえば AWS のサービスごとにファイルを分け、1 ファイルに複数のリソースをまとめて書くことがあります。

その後、リソースが増えてきてファイルが大きくなってきたときにモジュール化するなどして、はじめてファイルを分割しようとなります。

その場合、素朴にモジュールに切り出しても、Terraform の状態を保持する tfstate の整合性がとれなくなり、意図しない差分が出て困ることになります。

そのような場合には `state mv` コマンドが役に立ちます。

[Command: state mv - Terraform by HashiCorp](https://www.terraform.io/docs/commands/state/mv.html)

## :dango: `state mv` を使ったリファクタリング例

ここでは、以下のように `elasticache.tf` に定義されている 2 つの ElastiCache クラスタ (Redis) をモジュールに切り出し、`elasticache/foo.tf` と `elasticache/bar.tf` に分けることを考えます。

この例で用いる Terraform のバージョンは v0.11.7 、provider.aws のバージョンは v1.18.0 とします。

```hcl
# elasticache.tf

resource "aws_elasticache_replication_group" "foo" {
  replication_group_id          = "foo"
  replication_group_description = "foo"
  node_type                     = "cache.t2.micro"
  engine_version                = "3.2.10"
  number_cache_clusters         = 1
  port                          = 6379
  parameter_group_name          = "default.redis3.2"
  availability_zones   = [
    "ap-northeast-1c",
  ]
  subnet_group_name             = "usagoya-default"
  security_group_ids   = [
    "sg-b04bf3d7", # default@usagoya
  ]
  auto_minor_version_upgrade    = false
  apply_immediately             = true
}

resource "aws_elasticache_replication_group" "bar" {
  replication_group_id          = "bar"
  replication_group_description = "bar"
  node_type                     = "cache.t2.micro"
  engine_version                = "3.2.10"
  number_cache_clusters         = 1
  port                          = 6379
  parameter_group_name          = "default.redis3.2"
  availability_zones   = [
    "ap-northeast-1c",
  ]
  subnet_group_name             = "usagoya-default"
  security_group_ids   = [
    "sg-b04bf3d7", # default@usagoya
  ]
  auto_minor_version_upgrade    = false
  apply_immediately             = true
}
```

これを 1 ファイル 1 クラスタにファイル分割しようと思うと、モジュールを利用して以下のように定義することになります。

```
# elasticache.tf


module "elasticache" {
  source = "./elasticache"
}
```

```
# elasticache/foo.tf

resource "aws_elasticache_replication_group" "foo" {
  replication_group_id          = "foo"
  replication_group_description = "foo"
  node_type                     = "cache.t2.micro"
  engine_version                = "3.2.10"
  number_cache_clusters         = 1
  port                          = 6379
  parameter_group_name          = "default.redis3.2"
  availability_zones   = [
    "ap-northeast-1c",
  ]
  subnet_group_name             = "usagoya-default"
  security_group_ids   = [
    "sg-b04bf3d7", # default@usagoya
  ]
  auto_minor_version_upgrade    = false
  apply_immediately             = true
}
```

```
# elasticache/bar.tf

resource "aws_elasticache_replication_group" "bar" {
  replication_group_id          = "bar"
  replication_group_description = "bar"
  node_type                     = "cache.t2.micro"
  engine_version                = "3.2.10"
  number_cache_clusters         = 1
  port                          = 6379
  parameter_group_name          = "default.redis3.2"
  availability_zones   = [
    "ap-northeast-1c",
  ]
  subnet_group_name             = "usagoya-default"
  security_group_ids   = [
    "sg-b04bf3d7", # default@usagoya
  ]
  auto_minor_version_upgrade    = false
  apply_immediately             = true
}
```

この状態で素朴に `terraform plan` を実行すると、以下のようにリソースを destroy して create するような実行計画が生成されます。

```
terraform get
- module.elasticache
  Getting source "./elasticache"
terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_elasticache_replication_group.foo: Refreshing state... (ID: foo)
aws_elasticache_replication_group.bar: Refreshing state... (ID: bar)

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:

  - aws_elasticache_replication_group.bar

  - aws_elasticache_replication_group.foo

  + module.elasticache.aws_elasticache_replication_group.bar
      id:                             <computed>
      apply_immediately:              "true"
      at_rest_encryption_enabled:     "false"
      auto_minor_version_upgrade:     "false"
      automatic_failover_enabled:     "false"
      availability_zones.#:           "1"
      availability_zones.249779250:   "ap-northeast-1c"
      cluster_mode.#:                 <computed>
      configuration_endpoint_address: <computed>
      engine:                         "redis"
      engine_version:                 "3.2.10"
      maintenance_window:             <computed>
      node_type:                      "cache.t2.micro"
      number_cache_clusters:          "1"
      parameter_group_name:           "default.redis3.2"
      port:                           "6379"
      primary_endpoint_address:       <computed>
      replication_group_description:  "bar"
      replication_group_id:           "bar"
      security_group_ids.#:           "1"
      security_group_ids.2335859803:  "sg-b04bf3d7"
      security_group_names.#:         <computed>
      snapshot_window:                <computed>
      subnet_group_name:              "usagoya-default"
      transit_encryption_enabled:     "false"

  + module.elasticache.aws_elasticache_replication_group.foo
      id:                             <computed>
      apply_immediately:              "true"
      at_rest_encryption_enabled:     "false"
      auto_minor_version_upgrade:     "false"
      automatic_failover_enabled:     "false"
      availability_zones.#:           "1"
      availability_zones.249779250:   "ap-northeast-1c"
      cluster_mode.#:                 <computed>
      configuration_endpoint_address: <computed>
      engine:                         "redis"
      engine_version:                 "3.2.10"
      maintenance_window:             <computed>
      node_type:                      "cache.t2.micro"
      number_cache_clusters:          "1"
      parameter_group_name:           "default.redis3.2"
      port:                           "6379"
      primary_endpoint_address:       <computed>
      replication_group_description:  "foo"
      replication_group_id:           "foo"
      security_group_ids.#:           "1"
      security_group_ids.2335859803:  "sg-b04bf3d7"
      security_group_names.#:         <computed>
      snapshot_window:                <computed>
      subnet_group_name:              "usagoya-default"
      transit_encryption_enabled:     "false"


Plan: 2 to add, 0 to change, 2 to destroy.
```

ここでは現状のリソースに影響を与えず Terraform のファイルだけに手を加えたいため、差分が出てしまっては困ります。この差分を解消するためには tfstate に手を加えてべた書きしたリソースをモジュールに移す、いわゆる tfstate 職人としての作業が必要になります。

ここでは `state mv` というサブコマンドを使うことで、tfstate を手で編集することなく、整合性をとることができます。この場合は以下のように `state mv` コマンドを実行するとよいです。

```
$ terraform state mv aws_elasticache_replication_group.foo module.elasticache.aws_elasticache_replication_group.foo
$ terraform state mv aws_elasticache_replication_group.bar module.elasticache.aws_elasticache_replication_group.bar
```

以下のように差分が消えていれば成功です。

```
terraform get
- module.elasticache
terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_elasticache_replication_group.foo: Refreshing state... (ID: foo)
aws_elasticache_replication_group.bar: Refreshing state... (ID: bar)

------------------------------------------------------------------------

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
```

`state mv` は [公式ドキュメント](https://www.terraform.io/docs/commands/state/mv.html)にあるように、Terraform ファイルのリファクタリングに有用なので、どんどん利用していきましょう :muscle: :rabbit: :sparkles:

---
title: 週報 (2019-06 3 週目) | Terraform の aws_budgets_budget resource の改良を進めたり Cafe Obscura でコーヒーを吸ったり
date: 2019-06-16
tags: diary
---

先週書いた [週報 (2019-06 2 週目) | Mimikyu というミドルウェアを書いたり Gato Roboto を一通りクリアしたり](/2019/06/08/weekly_report_2019_06_02.html) に引き続き、なんとか 3 週続きましたね。果たしてこの調子でこのまま毎週続けることができるのでしょうか。

今週のハイライトは、

- ブログ記事を一つ書いた
    - [ElastiCache の configuration endpoint のフリをする Mimikyu というミドルウェアを作った](/2019/06/15/mimikyu.html)
- Terraform の aws_budgets_budget resource 改善のための pull request を作るための作業をやっている
- [Salmon v0.4.1](https://github.com/mozamimy/salmon/releases/tag/v0.4.1) をリリースした
- Cafe Obscura でコーヒーを吸った

## Mimikyu に関するブログ記事を書いた

こちらです 👉 [ElastiCache の configuration endpoint のフリをする Mimikyu というミドルウェアを作った](/2019/06/15/mimikyu.html)

前回の週報でもチラ見せしたのですが、あらためてひとつの記事としてページを作って書いておきました。詳細はリンク先でどうぞ。

## Terraform の aws_budgets_budget resource 改善のための pull request を作るための作業をやっている

[Budget with multiple TagKeyValue cost filters · Issue #5890 · terraform-providers/terraform-provider-aws](https://github.com/terraform-providers/terraform-provider-aws/issues/5890) をどうにかするぞと思って、terraform-provider-aws をフォークしてちまちまと作業を進めています。とりあえず実装はできたのですが、まだテストを直す必要があります。

途中経過はこちら 👉 [https://github.com/mozamimy/terraform-provider-aws/commit/d5d68b9913719ef880ad93ff82dd4ffce54c9196](https://github.com/mozamimy/terraform-provider-aws/commit/d5d68b9913719ef880ad93ff82dd4ffce54c9196)

### AWS Budgets の `cost_filters` の指定が非直感的で一つのキーに複数の値を設定できない問題

AWS には予算を管理するための機能として [AWS Budgets](https://aws.amazon.com/aws-cost-management/aws-budgets/) という機能があり、Terraform の AWS provider もこれに対応しています。

AWS Budgets では予算の対象となるコストを様々な条件でフィルタできるようになっており、それはコンソールでは以下のスクリーンショットの赤線で囲んだ箇所にあたります。リージョンやタグなど、いろいろな条件が使えることがわかりますね。各条件に対して、複数の値をセットすることもでき、たとえば ap-northeast-1 と us-east-1 の OR 条件で絞り込む、ということができるようになっています。

<a href="/images/2019/06/16/budget.png">
  <img src="/images/2019/06/16/budget.png" style="width: 100%;">
</a>

これは Terraforn の `aws_budgets_budget` リソースの `cost_filters` に対応していて、

```
resource "aws_budgets_budget" "monthly_cost_budget" {
  # :
  # (snip)
  # :

  cost_filters {
    Region = "ap-northeast-1"
  }

  # :
  # (snip)
  # :
}
```

のような形で指定できますが、現状の実装では複数の値を設定することができません。つまり、残念ながら以下のような記述は違法です。

```
resource "aws_budgets_budget" "monthly_cost_budget" {
  # :
  # (snip)
  # :

  cost_filters {
    Region = [
      "ap-northeast-1",
      "us-east-1",
    ]
  }

  # :
  # (snip)
  # :
}
```

以下のリンク先のコードのように、`cost_filters` はコード上では `schema.TypeMap` として定義されていて、これは `Region` のような文字列のキーに対して、`ap-northeast-1` のような文字列の値がただ一つ設定できるという実装になっています。

[https://github.com/terraform-providers/terraform-provider-aws/blob/ffc8ed837dc72b36e43195faa4597c32b9fcb2db/aws/resource_aws_budgets_budget.go#L129-L133](https://github.com/terraform-providers/terraform-provider-aws/blob/ffc8ed837dc72b36e43195faa4597c32b9fcb2db/aws/resource_aws_budgets_budget.go#L129-L133)

ただ、コンソール上でも一つのキーに対して複数の値を設定できるようになっていますし、AWS Budgets の API も、当然複数の値をとれるようになっています。

今回 AWS Provider のコードをいじるにあたっても参考にした [Terraform Provider実装 入門(3): スキーマ定義 前編](http://febc-yamamoto.hatenablog.jp/entry/terraform-custom-provider-03) のページにあるように、`TypeMap` の各要素はプリミティブ型しか設定できないため、「以下のような記述は違法です」で示したコードスニペットのような書き方は、そもそもこの制限によって実現できなさそうです。

### この問題を解決するためにやろうとしていること

というわけで、そもそも今のスキーマを保ったまま `cost_filters` をどうにかすることは無理そうで、互換性を犠牲にしつつもなるべくショックを和らげるために、以下のように解決するパッチを書いています。

- `schema.TypeSet` 型をもつ `cost_filter` という要素を新しく作り、`name` に `Region` のようなキーを、`values` に `ap-northeast-1` などの値を配列として指定できるようにする。
- `cost_filters` は続投するが非推奨とし、`cost_filter` と排他的に設定できるようにする。

つまり、もしわたしが書いているパッチが採用されれば、以下のようにフィルタを書くことができるようになります。

```
resource "aws_budgets_budget" "monthly_cost_budget" {
  # :
  # (snip)
  # :

  cost_filter {
    name = "Region"
    values = [
      "ap-northeast-1",
      "us-east-1",
    ]
  }

  cost_filter {
    name = "PurchaseType"
    values = [
      "Spot",
    ]
  }

  # :
  # (snip)
  # :
}
```

これは [aws_db_parameter_group resource](https://www.terraform.io/docs/providers/aws/r/db_parameter_group.html) の `parameter` と同じような考え方に基づいています。

### 開発がすごくたいへん😫

書いてる途中のパッチの変更の行数は少ないように見えますが、そもそも Terraform のプラグイン機構の仕組みやスキーマの概念を理解するところからスタートだったので、思ったよりも時間がかかっています。

しかも AWS provider の開発は割と非人道的で、

- コードに変更を加える → ビルドする → 実際に terraform plan/apply を実行して動作確認するの 1 サイクルに時間がかかる
- `interface{}` の多用により、コード上のあらゆる箇所で動的に型を解決しなければならないため、静的型付けの恩恵が受けられず、まずいコードをかくと実行時に容易にパニックする

の二重苦で、結構骨が折れます。コンパイルが速いと言われる Go でも、この規模になると t3.xlarge のような結構性能の良いインスタンスでも数十秒は待たされます。まずいコードを書くと実行時にパニックするのも結構つらくて、コンパイル時間の対価として受け取ることができるはずの静的型付けの恩恵が受けられず悲しい気持ちになります。アクティブなメンテナの方は、いつもどうやって開発してるんだろうというのが気になるところ。

あとはテストの修正とドキュメントの修正をすれば晴れて pull request にできるので、ゆるゆる頑張っていこうと思います。これでもし reject されたらけっこうへこむかも..。

## Salmon v0.4.1 をリリースした

ダウンロードは以下のリンクから。

[https://github.com/mozamimy/salmon/releases/tag/v0.4.1](https://github.com/mozamimy/salmon/releases/tag/v0.4.1)

ヘルプメッセージの細かな改善と、設定ファイル (salmon.yaml) の `site_root` を `https://example.com` と `https://example.com/` の両方の形式で設定できるようにしました。実装が雑すぎて、`https://example.com/` のように設定されているとき、OGP の画像 URL が https://example.com//images/nanika.jpg のようになってしまっていたので修正です...。

## Cafe Obscura でコーヒーを吸った

先週の日曜日、知人の方と三軒茶屋にある [Cafe Obscura](https://obscura-coffee.com/) に行ってコーヒーを吸ってきました。以下の写真は、コーヒーとコーヒーを吸う前に食べたお肉です。

![](/images/2019/06/16/niku.jpg)

![](/images/2019/06/16/coffee.jpg)

ルワンダともう一杯 (名前を忘れてしまった..) をいただいたのですが、とてもおいしかったです。フルーティな感じで。

## 🐇 今週のルカチャン

たまにみみがピーンと立つのですが、なぜかいつも片耳だけ。両耳ピーンと立っているところは見たことがないです。

![](/images/2019/06/16/ruka_pin.jpg)

夜行性だといわれがちなうさぎさんですが、正確には薄明薄暮性といって、朝方と夕方に活発になります。ルカチャンもその例にもれず昼間は熟睡していることが多いのですが、たまにちょっと白目をむいて眠ってます...。いい夢をみてるといいのだけれど。

![](/images/2019/06/16/ruka_hanme.jpg)


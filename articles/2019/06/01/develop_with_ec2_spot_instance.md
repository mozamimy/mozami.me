---
title: Spot Fleet を使って割安にリモート (AWS) に開発環境を持つためのアレコレ
date: 2019-06-01
tags: programming, infra
---

みなさん、開発をやっていますか? わたしはやっています。

わたしはどちらかといえば「なるべくモノを持たない主義」なので、家に計算機をあまり置かないようにしています。とはいえ、IX2105 といったルータやスイッチの類や、HP の MicroServer N54L が元気に稼働してたりはしますが..。

それはさておき、家に開発用に大きなデスクトップマシンを置きたくないということもあり、ここ数年はさくらの VPS で借りたインスタンスをリモートの開発マシンとして利用していました。ただ、ご家庭の計算機環境の Infrastructure as Code を実践し始める前からの年季の入ったインスタンスで、雑草が生え放題になっていてツギハギでなんとか動いているといった様子でした。また、使っていないときも動いているため、月額で契約する VPS は割高だなあという気持ちもありました。

そこで、開発環境をガッと AWS に移すことに決め、さらにスポットインスタンスを活用して、性能の良いインスタンスを割安に使える環境を作ることに決めました。

いろいろモゾモゾと整備して、まだ改善点はあるものの、だいぶいい感じになってきたのでメモがてらブログ記事にまとめようと思います。

## 開発環境の立ち上げから終了までのフロー

詳細に入る前に、まずはどのような感じで開発環境を立ち上げて、作業に飽きたら終了しているのかを順番に書いていきます。

- `rake workbench:launch` という Rake タスクで Spot Fleet request を作ってインスタンスを立ち上げる。
- `ssh workbench-001.apne1.aws.mozami.me` といった感じでインスタンスにログインして作業する。
- 作業に疲れたら `rake workbench:terminate` という Rake タスクで Spot Fleet request を削除し、インスタンスを terminate する。

常に起動しているインスタンスに ssh するだけという手軽さには劣りますが、3 分もすれば起動するので、その間にコーヒーをいれるなりうさぎを撫でるなりしていれば、あっという間に作業環境が整います。

## インスタンスを立ち上げるための Rake タスク

ご家庭の計算機環境を Infrastructure as Code するためのリポジトリは GitHub にあるのですが、さすがにこれはパブリックにはできないので、そのリポジトリに含まれるインスタンスを立ち上げるための Rake タスクをチラ見せします。

<p>
{{ embed_code "/2019/06/01/rake.rb" }}
</p>

コードとしてはちょっと長いように見えますが、ほとんどが Spot Fleet request や launch specification の設定値で、やっていることは単純です。

- **起動時**
    - Role タグが `workbench` になっている AMI の中から最新のものを探す。なければ `base` となっている AMI を探す。
    - 最新の AMI の ID を launch specification の設定に含める。
    - その launch specification の設定を使って Spot Fleet request を作成する。
        - 適当にインスタンスタイプと availability zone の候補を `launch_specification` として並べておき、`allocation_strategy` を `lowestPrice` に設定しておけば、その瞬間の時価で一番安いインスタンスが立ち上がる。
    - Spot Fleet request の ID をローカルのディスクに書く。
- **終了時**
    - 動いているインスタンスの AMI を作る。
    - ディスクから Spot Fleet request の ID を読んで、その request をキャンセルする。
    - キャンセルにより無事インスタンスが終了する。

だいぶとサボった実装ですが、Spot Fleet request をディスクに書き込む代わりに、S3 を KVS として利用するのも手かもしれませんね。そもそも、Spot Fleet request がタグをサポートすればこんなことをする必要はないのですが..。

また、インスタンス名は workbench-001 と固定するよりも、workbench-i-xxxxxx のように、インスタンス ID を利用した名前にするともっと良いかもしれません。ただ、この場合は開発用途なので重複して立ち上げることはなく、これで十分です。

この設定だと、だいたいはもっとも安い価格で安定している t3.xlarge が立ち上がってきます。Spot Fleet request は現在起動しているインスタンスの時価を見て立ち上げ直すということはしてくれないため、そこは注意する必要があります。

また、起動と終了を繰り返すたびにモリモリと AMI や EBS snapshot が増えていくため、定期的に古いものを削除したほうが節約になります。このあたりはまだ自動化しておらず、気づいたときにちまちま消しています。

## ssh でシュッとインスタンスにログインする

インスタンスの DNS 名の管理は、CloudWatch events からインスタンスの立ち上げと終了のイベントを取得して、Route 53 の private hosted zone に A レコードを追加/削除するだけの雑な Lambda function で管理しています。ご家庭にひとつはありそうな仕組みですね。

[mozamimy/route53-register: A CloudFormation stack which includes a Lambda function and a CloudWatch event to create/delete A record when launching/terminating EC2 instance](https://github.com/mozamimy/route53-register/)

これにより workbench-001.apne1.aws.mozami.me という名前でインスタンスが立ち上がったときに A レコードが追加されてシュッと ssh ログインできます。いわゆる bastion が常設されていて、EC2 に ssh ログインするときはそれを踏み台にしているため、この名前は VPC 内で引けるだけで OK です。

手元のマシンの SSH config は Nymphia という Ruby の DSL で SSH config を生成するツールを利用しており、開発環境として利用するインスタンス名のみ、`StrictHostKeyChecking` を `no` に設定し、`UseKnownHostsFile` も `/dev/null` に設定しています。

[mozamimy/nymphia: Create your SSH config with Ruby, and without any pain.](https://github.com/mozamimy/nymphia)

こんな感じの設定を DSL を使って書いて、

<p>
{{ embed_code "/2019/06/01/nymphia.rb" }}
</p>

Nymphia で設定を生成すると、このような SSH config が出てきます。

```
Host workbench-001.apne1.aws.mozami.me
  User mozamimy
  Port 22
  ForwardAgent yes
  IdentityFile ~/.ssh/usagoya.pem
  ProxyCommand ssh gw.mozami.me -q -W %h:%p
  Hostname workbench-001.apne1.aws.mozami.me
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```

以前は Rust や Go を書くときに限っては VS Code を利用し、それ以外では Vim を使っていました。なので、リモートの開発環境でも VS Code で書きたいときに困っていたのですが、少し前に VS Code Remote Development が発表されて実用段階になり、今ではほぼ完全に VS Code に乗り換えました。

## データの置き場

スポットインスタンスを開発環境としたときに困るのが、データの置き場です。具体的には常用するためのユーザのホームディレクトリですね。開発用のインスタンスのプロビジョニングは [Packer](https://www.packer.io/) や [mitamae](https://github.com/itamae-kitchen/mitamae) を使っているため、base AMI からいつでも簡単に作ることができるので大した問題ではありません。

この点に関しては、EFS を利用することでクリアしました。EFS は AWS が提供するマネージドな NFS サービスで、`~/var` というディレクトリを NFS のマウントポイントとしています。これにより、突然 spot interruption を食らってもデータを失う心配がグッと減ります。データ用の EBS をアタッチし、毎度スナップショットをとってインスタンスを立ち上げるときにリストアしてアタッチして.. という方法もありますが、めんどくさい。

ただし、ストレージとしてのパフォーマンスは gp2 の EBS に比べるとかなり残念なので、その場合には `~/var` 以外のディレクトリ、たとえば `~/tmp` で作業することが多いです。データを失っても問題ないという前提付きになりますが。

## 実際の使用感と料金

このような構成で数ヶ月過ごしてきましたが、今の今まで、ただの一度も spot interruption を受けたことがありませんし、インスタンスの価格も約 70% off で開発環境をリモートで運用することができており、たいへん快適です。

以下のスクリーンショットは、Cost Explorer で、この開発環境周りのリソースに絞ってコストを集計したものです (2019-05)。

<img src="/images/2019/06/01/cost.png" style="width: 700px;">

平日は平均 1 ~ 2 時間、外出などをしない休日は 8 時間以上立ち上げることもありますが、t3.xlarge といったそこそこ贅沢なインスタンスを利用しているにもかかわらず、1 ヶ月にかかる料金としては、EC2 周りの料金と EFS を足し合わせて $10 を少し上回る程度です。さくらの VPS を利用していた頃は、¥3,888/month の 4G プランを利用していたので、かなり安上がりに済んでいますね。

この先、価格変動が大きくなったりするとここまで安定して使えなくなるかもしれませんが、逆に言えば安定している今こそ使い時だと言えます。みなさんも思い思いの、スポットインスタンスを利用したぼくがかんがえたさいきょうのリモート開発環境を構築してみてはどうでしょうか。たのしいですよ。

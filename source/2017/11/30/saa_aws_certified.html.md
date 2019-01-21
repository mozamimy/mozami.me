---
title: AWS Certified Solutions Architect (Associate) を受験して合格しました
date: 2017-11-30
tags: infra, AWS
---

こんにちは。[@mozamimy](https://twitter.com/mozamimy) です。先日機運が高まって AWS Certified Solutions Architect (Associate) を受験する気持ちになり、受験したら合格したのでメモを残しておきます。

ちなみにわたしのスペックは以下のような感じです。

- AWS 歴: 業務および個人で 1 年半程度
- 好きなサービス
  - ECS
  - ELB
  - Lambda

## ❓ なぜ突然 AWS の資格を受験する気持ちになったのか

もともと資格にはあまり興味がない性格なのですが、きっかけは [AWS re:Invent 2017 | Amazon Web Services](https://reinvent.awsevents.com/) に行くことになった、ということでした。

re:Invent は毎年ラスベガスで行われている AWS 主催の最大のカンファレンスで、毎年 Keynote で新サービスの発表が行われたり、AWS を活用している様々な技術者の発表を聞いて知見をためたり、世界中の人と交流できるお祭りイベントです。

インフラエンジニアに転向してから re:Invent には一度は行ってみたいなと思っていて、2017 年の今年はそのチャンスがめぐってきたのでラスベガスまで飛ぶことになりました。実はこの記事も、ラスベガスの The Venetian というホテルで休憩時間を使って書いています。

re:Invent では、AWS 認定試験の資格保持者だけが入れる Certification Lounge があり、資格をとっておくとちょっとした優越感とともにラウンジを利用できるというウワサを聞いていたので、とても邪な理由だなあと思いつつ、勉強にもなるし資格は持ってて損はないので受験することにしました。

ちなみに、この Certification Lounge は別名 **人権ラウンジ** と呼ばれ、仲間内では人権が「ある」or「ない」で通じるという、ハイコンテキストな会話が繰り広げられています。

## 📃 試験問題に対する雑感

[AWS 認定 – AWS クラウドコンピューティング認定プログラム | AWS](https://aws.amazon.com/jp/certification/) の認定ロードマップを見てみると、Solutions Architect をはじめ、AWS 認定にはいくつかの種類の資格があります。わたしは知人にオススメされた Solutions Architect (Associate) を受験しました。

Solutions Architect (Associate) は割と簡単で、試験も日本語で受けられることから、最初にチャレンジする資格としては人気なようです。

今後変わる可能性もあるので必ず確認してほしいですが、[試験の要項](https://d1.awsstatic.com/training-and-certification/docs-sa-assoc/AWS_certified_solutions_architect_associate_blueprint.pdf) を見てみると、出題範囲と内訳は以下になります。

- 1.0 Designing highly available, cost-efficient, fault-tolerant, scalable systems: 60%
- 2.0 Implementation/Deployment: 10%
- 3.0 Data Security: 20%
- 4.0 Troubleshooting: 10%

割とフンワリしていて非常にわかりづらいのですが、実際に受験してみると、以下のような問題が出ていた印象でした。あまり詳しくかけないのであくまで雰囲気です。

- VPC, EC2, ELB, S3 といった定番サービスに関する **細かい** 知識を問う問題
- たまに Route 53 や RDS などのマネージドサービスに関する問題
- CloudWatch, CloudTrail, OpsWorks, CloudFormation, Trusted Advisor といった管理・デプロイ系ツールの基本的な知識を問う問題
- IAM や KMS などのアイデンティティやセキュリティに関わるサービスと、AWSのセキュリティと責任共有モデルへの理解

本当に **細かい** ところまで問われます。特に VPC や EC2 まわりはそれなりに長く使ってるし大丈夫だろうと高をくくって受験すると、手痛いしっぺ返しを食らうことになるでしょう。

## 💯 評点

日本各地に点在するキオスク端末に出向いて試験を受けるため、結果はその場で分かります。届いたメールをそのままコピペ。

```
改めまして、認定取得おめでとうございます。

総合評点： 85%

トピックレベルスコアリング：
1.0  Designing highly available, cost-efficient, fault-tolerant, scalable systems: 90%
2.0  Implementation/Deployment: 100%
3.0  Data Security: 81%
4.0  Troubleshooting: 40%
```

合格はしたものの、**Troubleshooting のスコアの残念さ... 一体何が起こったんだ...**

ちなみにボーダーは公開されていないものの、ウワサによると 65% ~ 75% あたりだと言われています。余裕を持って 90% 以上はとるくらいの気合でいくと合格できる可能性は高そうです。

## 📝 試験日までにやったこと

羅列すると以下のような感じです。

- ウェブ検索で見つけた体験記や知人から情報を集める。
- 模擬試験を受ける。
- どのあたりの知識を問われるのか、アタリをつける。
- [AWS クラウドサービス活用資料集 | AWS](https://aws.amazon.com/jp/aws-jp-introduction/) を熟読する。
- 試験当日がんばる。

参考にした体験記はたくさんあるのですが、たくさんありすぎて、もはやどこを見たか覚えていません.. 適当にウェブで検索してみてください。

有料ですが、勉強を始める前に模擬試験を受けることを強くオススメします。勉強を始める前に模擬試験を受けることで、今現在の力量を正確に測ることができます。ちなみにわたしは、模擬試験を受けた段階では 75% でした。業務でさんざん使ってるし大丈夫だろうと思ってましたが、意外と綱渡り状態でちょっと焦り始めます。

ここまでの情報収集と模擬試験により、どのような問題が出るのかだいたいアタリがつくので、次はそれに合わせて勉強するのみです。わたしは勉強を始めたのが試験日の 5 日前であまり時間もなかったことと、知人のオススメということで、教材は [AWS クラウドサービス活用資料集 | AWS](https://aws.amazon.com/jp/aws-jp-introduction/) 一本にしぼりました。

とにかく読み散らかしたのでどれを読んだかよく覚えていないですが、以下の資料は是非読んだほうがよいです。初期状態での経験値にもよりますが、さすがに 1 年強も AWS を触っていると知ってることが多いと思います。ただ、本当に **細かい** ところまで問われるので、しっかりと目を通しておくことをオススメします。

- EC2 関連すべて
  - Auto Scaling や EBS を含む
- ELB
- S3, Glacier, Storage Gateway, EFS
- CloudFront
- RDS, DynamoDB, ElastiCache, Redshift
- VPC, Direct Connect
- Codestars
- CloudWatch, CloudFormation, OpsWorks, AWS Config, CloudTrail, Trusted Advisor
- KMS, IAM
- EMR, Kinesis
- Cognito, SNS, SQS
- Route 53
- AWSにおけるセキュリティとコンプライアンス

また、これらを単独で丸暗記しただけではダメで、各サービス間の関係性などが頭のなかに入っていて、「これこれこうするには、どのようなアーキテクチャで組めばいいですか?」というような質問に答えられるようにしないといけません。ソリューションアーキテクトなのだから、当然ですね。実務経験があるとこの辺の勘は十分に働くと思います。

また、必要に応じて公式ドキュメントも熟読することをオススメします。

実務で 1 年以上 AWS を使っていれば、以上のような方法で勉強すれば合格することは難しくないでしょう。

## 💭 まとめ

ざっと AWS Certified Solutions Architect (Associate) の資格試験に合格するまでの道のりをメモしました。この記事が、どなたかのお役に立てば幸いです。もし re:Invent に行く機会があれば、ぜひとも人権をゲットした上で参加することをオススメします！

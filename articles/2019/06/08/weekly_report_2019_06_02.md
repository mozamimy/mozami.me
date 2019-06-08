---
title: 週報 (2019-06 2 週目) | Mimikyu というミドルウェアを書いたり Gato Roboto を一通りクリアしたり
date: 2019-06-08
tags: diary
---

先週から始めてみた週報ですが、とりあえず 2 回は続きました。二度あることは三度あるということわざもあるので、このまま毎週続けられるといいですね。

先週の記事はこちら。

[週報 (2019-06 1 週目) | Salmon v0.4.0・電気ブランとか Night in the Woods とか](/2019/06/01/weekly_report_2019_01.html)

今週のハイライトは、

- [Mimikyu](https://github.com/mozamimy/mimikyu) というミドルウェアを書いた
- [terraform-aws-provider](https://github.com/terraform-providers/terraform-provider-aws) の aws_budgets_budget resource の `cost_filters` に配列を指定したい
- ゲームをした
    - [Gato Roboto](https://ec.nintendo.com/JP/ja/titles/70010000013633) を一通りクリアした
    - [嘘つき姫と盲目王子](https://ec.nintendo.com/JP/ja/titles/70010000007612) をプレイし始めた
- うさぎ用品の買い足しをした

といった感じです。

## Mimikyu というミドルウェアを書いた

リポジトリは以下のリンクから。

[mozamimy/mimikyu: Tiny proxy of ElastiCahce Memceched configuration endpoint](https://github.com/mozamimy/mimikyu)

Docker Hub にも Docker イメージを push してあります。

[mozamimy/mimikyu - Docker Hub](https://cloud.docker.com/u/mozamimy/repository/docker/mozamimy/mimikyu)

どのようなミドルウェアなのかを一言でいうと、AWS の ElastiCache Memcached のクラスタ間での切り替えをラクにするためのミドルウェアです。

TCP ポートで listen し、Memcached クライアントから見ると configuration endpoint のように振る舞って、上流の 2 つのクラスタに含まれるノードの一覧を結合して返すだけの、一種の Memcached プロキシです。

GitHub リポジトリの README に書いてある図のそのままの引用になりますが、こんなイメージです。

<a href="/images/2019/06/08/how_mimikyu_works.png">
  <img src="/images/2019/06/08/how_mimikyu_works.png" style="width: 700px;">
</a>

cache-cluster-alpha と cache-cluster-beta という 2 つのクラスタがあり、それぞれのクラスタに 2 ノードずつ含まれているとき、Mimikyu は `config get cluster` コマンドを受け取ったときにそれらのノードをがっちゃんこして返すだけのシンプルなサーバですね。

どういう場合に使えるのか、などなどの詳しい話は別の記事にまとめようと思っています。

ちなみに名前の由来は[ミミッキュ](https://www.pokemon.co.jp/ex/sun_moon/pokemon/160719_06.html)です。あたかも configuration endpoint のフリをするというところがそれっぽいかなと思っています。ポケモンの新作が今から楽しみですね。

## terraform-aws-provider の aws_budgets_budget resource の cost_fitlers に配列を指定したい

AWS には [Budgets](https://aws.amazon.com/aws-cost-management/aws-budgets/?nc1=h_ls) という機能があり、月ごと、クォーターごと、年ごとなどの期間で予算を設定し、その進捗を一覧として表示したり一定のしきい値を超えた場合に SNS topic を通して通知を発行したりできる便利な機能があります。

Terraform の AWS provider では [`aws_budgets_budget` resource](https://www.terraform.io/docs/providers/aws/r/budgets_budget.html) が利用可能で予算の設定をコード管理できるようになっているのですが、`cost_filters` の key に対する value が文字列であるため、たとえば「ap-northeast-1 と us-east-1 をがっちゃんこしたい」という場合に困るのですよね。コンソールからは一つの key に対して複数設定できますし、Budgets API もコストフィルタの値は配列で受け取るようになっています。

同じように困っている人がいて、[Budget with multiple TagKeyValue cost filters · Issue #5890 · terraform-providers/terraform-provider-aws](https://github.com/terraform-providers/terraform-provider-aws/issues/5890) という issue が立っており、せっかくなので普段便利に利用しているプロダクトに貢献したいという気持ちもあるので、コードを読みつつゆるゆるとパッチを送るための作業を進めています。

ただ、Terraform provider の開発は、デバッグが難しい (というか面倒) なきらいがあるため、プロの人に効率よく開発するためのワザを教えてほしい..。

## Gato Roboto を一通りクリアした

先週の記事にも書きましたが、ちまちまプレイしていた Gato Roboto を一通りクリアして、無事にエンディングを見ることができました。装備がぜんぶそろって、最強のネコチャンに！

<img src="/images/2019/06/08/gato_roboto.jpg" style="width: 700px;">

換気システムのエリアをクリアしたあと、一方通行になってしまって取れないアイテムがあると思いこんでいて悲しい気持ちになっていたのですが、アップデートで修正されたのかわたしが見落としてたのか、道を見つけて無事にビッグショットを回収することができました。

エンディングは... めでたしめでたしといえばそうなのですが、ちょっとかわいそうだなーというオチでした。ちょうどいい難易度でセリフの掛け合いも面白いので、ぜひキミの目で確かめてみてほしい！

## 嘘つき姫と盲目王子というゲームをプレイしはじめた

Gato Roboto も一通り遊んだので、次は何をやろうかなーと思ってオンラインストアを物色していたときに見つけたゲームです。ちょうどセールで半額だったのと、スクリーンショットを見て「かわいい！」と思って一目惚れして、気づけば PayPal 決済の画面に飛んでいました。

まだ冒頭部分しかプレイしていませんが、こんな雰囲気のゲームです。

<img src="/images/2019/06/08/wolf_hime.jpg" style="width: 700px;">

オープニングから結構重たい話が展開されて、心にズキズキくる感じがたまりません。ゲーム画面やイラスト、音楽、世界観など、全部がわたし好みな感じでどんどん引き込まれていってます。主人公の狼の子と自分を重ね合わせて、すごく共感できてしまうのですよね...。王子さまもショタかわいい...。

基本的に、できる限り事前情報を仕入れずに遊ぶのが好きなので、ボリューム感もまったくわからないまま進めていますが、来週にはエンディングを見れる感じなのかなーどうかなーと思っています。

## うさぎ用品を買い足した

気分転換がてら、うさぎのしっぽへうさぎ用品の買い足しに出かけつつ、旬八青果店で野菜を買ったり、東急ストアで買物をしていました。

<img src="/images/2019/06/08/usagi.jpg" style="width: 700px;">

少し前までは別のトイレ砂を利用していたのですが、こちらのほうが少し高い分性能が良いです。

ちょっと前に買ったおやつのにんじんしりしりがなくなりつつあるので、今度はだいこんしりしりを買ってみました。我が家ではおやつは二段構え制となっており、定番の乾燥パパイヤと、にんじんしりしりや今回のだいこんしりしりのように、なくなるたびに別のものに入れ替わる期間限定おやつを用意しています。ブーデーになってきているということもあり、加糖のおやつは与えないようにしています。

もじゃもじゃはﾙｶﾁｬﾝに大人気のおもちゃで、ケージに設置すると楽しそうにホリホリするのでリピしました。おもちゃは藁でできたものを中心に与えていて、食料も兼ねています。破壊の女王ﾙｶﾁｬﾝのひっさつまえばとみだれひっかきにかかれば、大きめのおもちゃであればだいたい 1 ~ 2 ヶ月で破壊し尽くすため、それくらいのスパンでいろいろなおもちゃを買ってきています。

うさぎの住まいをどのようにデザインしているかは、[Scrapbox のページ](https://scrapbox.io/mozamimy-public/%E3%82%B1%E3%83%BC%E3%82%B8%E3%81%AE%E3%83%AC%E3%82%A4%E3%82%A2%E3%82%A6%E3%83%88) にもまとめてあるので、興味があればご覧ください。世の中にはうさぎ飼いの方はたくさんいると思うのですが、このような形で情報をまとめている人ってほとんどいないと思うんですよね。わたしはすごく興味があるのですが...。

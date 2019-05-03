---
title: インターネットルーティング入門 第 3 版を読んだ
date: 2018-05-04
tags: book-review, infra
---

この本です。

<div class="amazlet-box" style="margin-bottom:0px;"><div class="amazlet-image" style="float:left;margin:0px 12px 1px 0px;"><a href="http://www.amazon.co.jp/exec/obidos/ASIN/4798134813" name="amazletlink" target="_blank"><img src="https://images-fe.ssl-images-amazon.com/images/I/51m7n6f4rbL._SL160_.jpg" alt="インターネットルーティング入門 第3版 (ネットワーキング入門)" style="border: none;" /></a></div><div class="amazlet-info" style="line-height:120%; margin-bottom: 10px"><div class="amazlet-name" style="margin-bottom:10px;line-height:120%"><a href="http://www.amazon.co.jp/exec/obidos/ASIN/4798134813" name="amazletlink" target="_blank">インターネットルーティング入門 第3版 (ネットワーキング入門)</a><div class="amazlet-powered-date" style="font-size:80%;margin-top:5px;line-height:120%">posted with <a href="http://www.amazlet.com/" title="amazlet" target="_blank">amazlet</a> at 18.05.05</div></div><div class="amazlet-detail">友近 剛史 池尻 雄一 白崎 泰弘 <br />翔泳社 <br />売り上げランキング: 146,269<br /></div><div class="amazlet-sub-info" style="float: left;"><div class="amazlet-link" style="margin-top: 5px"><a href="http://www.amazon.co.jp/exec/obidos/ASIN/4798134813" name="amazletlink" target="_blank">Amazon.co.jpで詳細を見る</a></div></div></div><div class="amazlet-footer" style="clear: left"></div></div>

## 💡 読もうと思ったきっかけ

ふだんウェブサービスのインフラを触ることが多いのですが、もう少し下のレイヤ、つまり L2, L3 あたりの知識がふんわりとしていて、もっとキッチリと「わかり」たいと思ったのがきっかけです。

また、今年は趣味のご家庭インフラの式年遷宮を計画していて、IX2105 のようなちゃんとしたルータを入手したので、拠点間 VPN などを仕込むことも考えており、ルーティングについて体系的に学ぶことが必ず役に立つだろうと考えたからです。

## 📕 内容と所感

ウェブサービスの開発や運用に携わっている人ならほぼ知っているであろうルーティングの仕組みの基礎から始まり、OSPF、RIP、BGP、MPLS といったプロトコルに関する説明に入り、最後は OpenFlow などの仮想ネットワークの概要について解説する、という流れになっていました。

また、それぞれのプロトコルの解説のあとには、Cisco の iOS 向けの設定例が載っているので、マニュアルとあわせて見ながら実際に手を動かして構築することで理解を深めることもできてよかったです。プロトコルがどの RFC に定義されているのかも書かれているため、一通り理解したあとは、RFC へのインデックスとして利用することもできそうです。

入門と銘打っているように、より複雑なネットワークを普段から触っているエキスパートにとっては基本的なトピックの解説にとどまっていそうです。しかし、エキスパートな人々が使う語彙を得ることができるため、そのような人々と会話したり質問したりするときに役立つ知識を得ることができました。

## 💻 やってみた

良書ですが、読むだけではわかったつもりになりがちなので、実際に OSPF や RIP、BGP などをしゃべらせてみるのがいいと思います。実機がたくさんあれば最高ですが、そうでなければ [Packet Tracer](https://www.netacad.com/courses/packet-tracer) を使って練習するのが一番お手軽だと思います。

以下のリポジトリに、実際に Packet Tracer 上に構築したものをアップロードしました。

[mozamimy/routing_sandbox: Cisco Pakcet Tracer files for my practice of routing and networking.](https://github.com/mozamimy/routing_sandbox)

たとえば以下のスクリーンショットは、コスト付きの OSPF の設定例です。

<a href="/images/2018/05/04/internet_routing/internet_routing_3.3.4.png">
<img alt='ルーティングの例' src='/images/2018/05/04/internet_routing/internet_routing_3.3.4.png' style="width: 700px;">
</a>

ただし、Packet Tracer には以下の制約があり、後半の設定例を試すことができませんでした。iOS のイメージが必要になりますが [GNS3](https://www.gns3.com/) というツールが使えるようです。

- iBGP を構成できない
- MPLS を構成できない

とはいえ、実際に使うことが多いであろう、OSPF や RIP によるネットワークを構成することは十分可能です。ルータの電源を急に落としたり線を切ったりして、OSPF や RIP が期待通りに動くかどうかを試してみると、ますます理解が深まると思います。

## 😤 まとめ

ちゃんとしたルータを購入していろいろやってみたい、でも知識がふんわりしててもっと理解したい人にとって、必ず役に立つ良書だと感じました。ご家庭インフラをシュッとさせるために活用していこうと思います 🐰✨

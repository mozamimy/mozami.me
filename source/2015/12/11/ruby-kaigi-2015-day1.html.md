---
title: RubyKaigi 2015 Day1
date: 2015-12-11
tags: ruby
---

<img src='/2015/12/11/ruby-kaigi-2015-day1/sushi.png' style='width: 200px;'>

前々から一度行きたいと思っていた、最大規模の Ruby の祭典、RubyKaigi 2015 に行ってきました。
2015-12-11(Fri.)〜2015-12-13(Sun.) の 3 日間構成で、東京の汐留で開催されています。

ザックリ速報として、発表内容を以下にまとめてみました。

## Keynote

cf. [http://rubykaigi.org/2015/presentations/matz](http://rubykaigi.org/2015/presentations/matz)

Ruby のパパ、Matz さんの発表です。

プログラマの三代美徳から始まり、Ruby を作ったきっかけとその発展について軽く触れ、
Ruby 2.3.0 の新機能をザックリとまとめていました。

最終的に Ruby 3 の展望について語っており、Ruby 3 では Ruby 2.0 と比較して 3 倍パフォーマンスを良くするとのことでした。
不可能ではなさそうですが、かなり大変そうだなー.. という印象が。

個人的には Streem の誕生秘話が面白くて、なんとなく実験的に作ってひっそり GitHub に置いていたものが、
いつの間にか情報が拡散されて提案やプルリクがガンガンくるようになったとのこと。

すごい人がおもしろいモノを作ってると、自然に人が集まってきて OSS が発展していくのは、OSS ならではの面白さですね。

## Compiling Ruby Scripts

cf. [http://rubykaigi.org/2015/presentations/ko1](http://rubykaigi.org/2015/presentations/ko1)

@ko1 さんの発表です。

Rubyのコンパイル済みコードをシリアライズ・デシリアライズするものを作った、という発表でした。
「Rubyのしくみ」という本を読んでいたおかげで、内容はすんなり理解できました。

聴きながらどこで役に立つかなーと思っていたのですが、@ko1 さんの言うように、
ライブラリをインストールするときにコンパイルしてしまって、ロードにかかるオーバーヘッドを軽減するという用途が
王道なのかなと思いました。

## Experiments in sharing Java VM technology with CRuby

cf. [http://rubykaigi.org/2015/presentations/MattStudies](http://rubykaigi.org/2015/presentations/MattStudies)

@MattStudies さんの発表です。

IBM は最近 Ruby に注目しているようで、Java VM で使っている JIT コンパイラなどの最適化テクニックを
cruby にがんばって応用してみたという話でした。

どうやら LLVM と競合するようなものを開発しているらしく、それなら OSS になっている LLVM のほうがこなれてるし良いのでは.. という感想。
ちなみに、「なぜ OSS にしないのか」という問に対して、登壇者いわく「それは IBM だからです HAHAHA」とのことでした。なるほど..

## mruby on the minimal embedded resource

cf. [http://rubykaigi.org/2015/presentations/shotantan](http://rubykaigi.org/2015/presentations/shotantan)

@shotantan さんの発表です。

mruby が載っていて、Ruby のコードをシュッと実行できるステキな組み込みボードのデモなどが中心でした。

組み込み分野でも、やっぱり C ですべてを書くのはしんどいとのこと。
mruby はそれなりに組み込み分野でも実用的に使えるそうですが、RAM の消費量の問題で、
ROM にメモリを swap するなりして工夫しないといけないそうです。

mruby の成果が今流行の IoT などに応用できうるので、温かく動向を見守っていきたいと思います。

## Fast Metaprogramming with Truffle

cf. [http://rubykaigi.org/2015/presentations/nirvdrum](http://rubykaigi.org/2015/presentations/nirvdrum)

@nirvdrum さんの発表です。

jruby と Truffle という仕組みの組み合わせで、メタプログラミングによって生えたメソッドのパフォーマンスが爆上がりしたよ、というのが
話の中心でした。

個人的な感想としては、「カッコいいー！でも、jruby なんでしょう？」というところに尽きました.. あまり jruby に良い思い出がないので..

## High Performance Template Engine: Guide to optimize your Ruby code

cf. [http://rubykaigi.org/2015/presentations/eagletmt_k0kubun](http://rubykaigi.org/2015/presentations/eagletmt_k0kubun)

@eagletmt さんと @k0kubun さんの発表です。

若さにあふれる発表で、パフォーマンス計測・ベンチマークの基本をサッとなぞって、
Faml や Hamlit がどういう風に生まれたのか、そして実装されているのかというテクニカルな話で面白かったです。

こくぶんさんのドギツイ Haml や Slim への dis が入っていましたが、わたし個人としては Syntax 含めて Slim が好みです。
だって `%` 打つのめんどくさいんだもん..

## TRICK 2015: The second Transcendental Ruby Imbroglio Contest for RubyKaigi

cf. [http://rubykaigi.org/2015/presentations/trick](http://rubykaigi.org/2015/presentations/trick)

TRICK というのは、Ruby で書くヘンなプログラム選手権で、2 回目の開催らしいです。
このセッションは、TRICK の受賞者のコードを鑑賞しましょうという内容でした。

ワンライナーや特徴的な見た目で書かれたキモいプログラムは圧巻で、創作意欲を刺激されました。

## セッションが終わってから

すべてのセッションが終わってからは特に予定がなかったのですが、関西にいたころの前職のエンジニアの方にお誘いただき、
ちょっとした飲み会に出ました。

環境が変わって新しい出会いも大切にしたいですが、こういう古い付き合いも大切にしないとなーと思いました。

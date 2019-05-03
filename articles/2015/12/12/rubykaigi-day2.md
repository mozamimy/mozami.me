---
title: RubyKaigi 2015 Day2
date: 2015-12-12
tags: diary, programming
---

<img src="/images/2015/12/12/rubykaigi-day2/sushi.png" style="width: 250px;">

昨日に引き続き、RubyKaigi の 2 日目に出席しました。
速報 & 自分用メモとしてザックリ内容をまとめます。

## Keynote

cf. [http://rubykaigi.org/2015/presentations/kosaki](http://rubykaigi.org/2015/presentations/kosaki)

@kosaki さんの発表です。

Day2 のスケジュールの開始時間を、Day1 と同様の 10:30 からと勘違いしていたため、聴くことができませんでした..

どうやら、カーネル開発のときに使われるデバッガを使いこなす的な内容だったようです（未確認）。

## The history of testing framework in Ruby

cf. [http://rubykaigi.org/2015/presentations/kou](http://rubykaigi.org/2015/presentations/kou)

@ktou さんの発表です。

前々からおさらいしたいと思っていた、Ruby におけるテストフレームワークの変遷について、
順を追っていい感じに聴ける発表でした。

最近ちょっと RSpec に辟易しているフシがあって、一周回って test-unit や minitest が大切にしている、
「Rubyらしく書ける」というコンセプトに惹かれるものがあります。

次に自分で何かを書くときは、test-unit か minitest を使ってみたいと思います。

## Turbo Rails with Rust

@@wycats さんの発表です。

cf. [http://rubykaigi.org/2015/presentations/wycats_chancancode](http://rubykaigi.org/2015/presentations/wycats_chancancode)

Rust でネイティブの Ruby 用 extension を書くためのノウハウが詰まった発表で、かなりためになりました。

Ruby 用に高速なライブラリを書きたいけど、C はあんまり書きたくない。
しかも、わたしは最近 Rust をよく触っていて Rust が推し言語なのでいっそう惹かれるものがありました。

libcruby という Rust 用のライブラリを使うと、Ruby から Rust で書いた関数を呼ぶためのグルーコードを肩代わりしてくれるので、
割と手軽にネイティブ extension が書けそうでした。

Ruby も Rust も大好きなので、Rust で何か gem を作ってみたいなーと思ったり。

## Data Analytics Service Company and Its Ruby Usage

cf. [http://rubykaigi.org/2015/presentations/tagomoris](http://rubykaigi.org/2015/presentations/tagomoris)

@tagomoris さんの発表です。

Treasure Data での顧客のためのビッグデータ処理を、どのようにうまくスケジューリングして
ワーカを動かしているかという発表でした。

システムは基本的に Ruby で構築されているそうで、一部 jruby や Java を使って実装しているとのこと。

Ruby を採用しているのは、クエリを組み立てるためのコードをメタプログラミングでうまく書け、
かつ RSpec を使うことでテストしやすいからだそうです。

## The future of Ruby is in motion!

@lrz さんの発表です。

cf. [http://rubykaigi.org/2015/presentations/lrz](http://rubykaigi.org/2015/presentations/lrz)

Ruby Motionの話で、登壇者いわく、昔から Ruby が好きで、かつ Apple の OS が好きなのが昂じて、
Ruby Motion に関わっているのだそう。

Ruby のコードを iOS アプリ化するために Ruby の AST を LLVM IR に落としているそうで、
ここでも LLVM 大活躍だなーと思いました。

デモでは、Flappy Sushi という Flappy Bird のクローンを作り、
ひとつの Ruby コードベースが iPhone エミュレータでも Apple TV でも動くというライブコーディングによる
デモを披露してくれました。

アプリを作ってみたいなーとぼんやり思っていたこともあって Swift を学ぶかと思っていたのですが、
Ruby Motion が思ってたよりもマトモ(失礼!)なので、選択肢として十分アリな気がします。

## Ruby meets Go

@＿mmasaki さんの発表です。

cf. http://rubykaigi.org/2015/presentations/mmasaki

Rust で extension を書く話と打って変わって、こちらは golang で Ruby を拡張する、というお話でした。

c-shared とよばれる golang から C の関数を呼ぶための仕組みを応用して、Ruby のネイティブ extension が作れるそうです。

見た感じ、Rust で作るよりもつらそうでした。
常に golang の世界、C の世界、Ruby の世界でのそれぞれでのデータの持ち方について気を配らなくてはならず、
ストレス無しに書くのは大変そうでした。

## Rhebok, High Performance Rack Handler

@kazeburo さんの発表です。

cf. [http://rubykaigi.org/2015/presentations/kazeburo](http://rubykaigi.org/2015/presentations/kazeburo)

unicorn よりも高速をうたう Rack Handler である Rhebok についての発表でした。

Rack Handler を実装するための基礎から徐々に Rhebok のつくりに入っていくという流れで、非常にわかりやすかったです。
ふんわりとしていた Rack についての理解が深まってためになりました。

## Pragmatic Testing of Ruby Core

@hsbt さんの発表です。

cf. [http://rubykaigi.org/2015/presentations/hsbt](http://rubykaigi.org/2015/presentations/hsbt)

どのように OSS に貢献したらよいのかという問いから入り、それはテストコードまわりだとやりやすいよ、
というところから話を展開していました。

メインの内容は Ruby のテスト周りのコードの解説でした。
Ruby Core のテストは、実際に Ruby に貢献しようと思ったら避けて通れない道なので、そのときには参考にしようと思いました。

## まとめ

最近 Rust が非常にお気に入りなので、Rust でネイティブエクステンションを書く話が刺さりました。

今日はこのあと、RubyKaigi のオフィシャルパーティがあるようなので、それにちょろっと顔を出して
最終日に備えようと思います。

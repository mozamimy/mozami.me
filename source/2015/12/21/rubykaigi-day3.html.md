---
title: RubyKaigi 2015 Day3
date: 2015-12-21
tags: ruby, ruby on rails
---

<img src="/2015/12/21/rubykaigi-day3/sushi.png" style="width: 250px;">

ちょっと日が空いてしまいましたが、先日に引き続いて、RubyKaigi の 3 日目について軽くまとめておきます。


## Ruby Comiitters vs the World

cf. [http://rubykaigi.org/2015/presentations/committers](http://rubykaigi.org/2015/presentations/committers)

Ruby コミッタの皆さんが、世界と戦うように見せかけて壇上でトークバトル(?) を繰り広げるというセッションでした。

Ruby を使っていて最近良く思うのは、動的な型システムって本当にいいのかな？という点です。
型推論が究極に賢くて、わざわざ型を書かなくても静的な型システムの恩恵を受けられるのがベストですが、
現実はなかなか難しい。

前に Matz さんが構想している Soft Typing では、そのへんがいい感じになるというウワサですが、
このセッションで進捗がないことが明らかになりました..

## It's dangerous to GC alone. Take this!

cf. [http://rubykaigi.org/2015/presentations/youngrw_CraigLehmann](http://rubykaigi.org/2015/presentations/youngrw_CraigLehmann)

先日に引き続き、IBM における OMR での GC テクノロジに関するお話でした。
ちょっとねむたくてよく覚えていないのですが、OMR の GC テクノロジを Ruby に適用してみたよ的な内容だったと思います。

## Refinements - the Worst Feature You Ever Loved

cf. [http://rubykaigi.org/2015/presentations/nusco](http://rubykaigi.org/2015/presentations/nusco)

強力すぎるモンキーパッチを、よりお行儀よい形で置き換えることのできる `refinements` の
基本と使い方についてのお話でした。

refinements、あまり使ったことがなくて理解がフワフワしていたのですが、よく理解することができました。
さすがメタプログラミング Ruby の著者だけあって、説明がわかりやすかったです。

実装には、dynamically scoped refinement と lexical scope refinements があって、
クラスの継承関係があるとややこしみが増えてしまうので、実際には lexical のほうが採用されたそうです。

感覚的には lexical というよりも local と言うほうがしっくりくる感じがしたのですが、
顛末な問題なので気にしないことにしました。

## Discussion on Thread between version 1.8.6 and 2.2.3

cf. [http://rubykaigi.org/2015/presentations/emorima](http://rubykaigi.org/2015/presentations/emorima)

Ruby の Thuread を 10000 スレッドでかつミッションクリティカルな環境で使ってみたよというお話でした。

途中で出てきたグラフに単位がなくて困惑しましたが、なんとか話を理解することができました。

Erlang などを使うという選択肢はなかったのですか？という問に、登壇者の方が
「ミッションクリティカルで実績のないものは使えません」とおっしゃったのには、Erlang 好きとしては、
ああ世間ではそういう評価なんだなーとちょっと悲しくなりました..

## Plugin-based software design with Ruby and RubyGems

cf. [http://rubykaigi.org/2015/presentations/frsyuki](http://rubykaigi.org/2015/presentations/frsyuki)

プラグインアーキテクチャを持つ gem を設計するためのテクニカルなお話がメインでした。

プラグインアーキテクチャの概念から、徐々に内容に入っていく感じでわかりやすかったです。
あんなキレイな設計ができるようになりたい..

## Request and Response

cf. [http://rubykaigi.org/2015/presentations/tenderlove](http://rubykaigi.org/2015/presentations/tenderlove)

生まれて初めて tenderlove さんを生で見たのですが、かわいい日本語で発表されていて度肝抜かれました。

比喩を用いた巧妙な表現で、Rails と Rack 周りが何をやっているのかをわかりやすく解説してくれました。
そしてお恥ずかしながら、HTTP2 がバイナリベースのプロトコルなのだと、ここで初めて知りました..

## Actor, Thread and me

cf. [http://rubykaigi.org/2015/presentations/seki](http://rubykaigi.org/2015/presentations/seki)

分散処理におけるアクターモデルと Ruby を絡めたお話でした。

アクターモデルは Erlang ではおなじみの概念で、登壇者の方の Queue と Thread で実装したアクターモデルは、
Thread を Process に置き換えると、Erlang のそれに似ているという印象でした。

そもそもですが、主に処理の並列化による高速化を狙う Thread と、リライアブルな分散処理を実現するための
アクターモデルを同じ土俵で比較するのって、何か無理があるなーと思ったりもしました。

## Keynote

cf. [http://rubykaigi.org/2015/presentations/evanphx](http://rubykaigi.org/2015/presentations/evanphx)

Matz さんが Ruby 3 では 3 倍高速にするという目標を打ち出しましたが、では、それを実際にどうやって
実現していくのかの具体的な提案を述べた発表でした。

登壇者いわくいちばん手っ取り早く効果が出そうなのは JIT らしく、JavaScript の V8 の仕組みや Rubinius が
LLVM IR を使っていたりすることに触れ、どうやったら速くなりそうか具体的に提案されていました。

## おわりに

いろいろとお勉強になったり、久しぶりに関西の Ruby な方とお話できたり、最高の 3 日間でした。

---
title: Rust でつくる VM 型の Brainf**k の処理系
date: 2017-04-19
tags: programming
---

これまで言語処理系のコンセプトこそ学んできたものの、実際に手を動かしてゼロから処理系を作る体験をしたことがなかったので、合間の時間を使ってガッと BF の処理系を作ってみました。
まず慣れている Ruby で実装して、その後、いま練習中の Rust で実装しました。この記事は、その記録になります。

## 実装の方針

BF は言語仕様が非常に小さいこともあり、初学者でも実装が簡単なため、ちょっとトリッキーな実装をしてみることにしました。
コードゴルフ的なアレではありません。完全に自己満足です。

- やらなくてもなんとかなりそうだけど字句解析と構文解析をする
- やらなくてもなんとかなりそうだけどコンパイラを作って仮想マシンの命令列にコンパイルする
- やらなくてもなんとかなりそうだけどわざわざ仮想スタックマシンで動かす

要するに、{字句,構文}解析 -> コンパイル -> 実行 の流れを一通り実装する感じです。cruby でも AST をコンパイルして YARV という仮想マシンで実行しますが、そんな感じです。
(というか、多分に影響を受けています)

## できた

エラーハンドリングが甘かったりテスト書いてないですが、動いてうれしかったのでとりあえず公開しました。

- Ruby による実装 Kaguya: [https://github.com/mozamimy/kaguya](https://github.com/mozamimy/kaguya)
- Rust による実装 Kaguya2: [https://github.com/mozamimy/kaguya2](https://github.com/mozamimy/kaguya2)

## 実装について

ここでは、Rust での実装を使ってコンポーネントごとに説明します。

### エントリーポイント

- Rust: [https://github.com/mozamimy/kaguya2/blob/master/src/main.rs](https://github.com/mozamimy/kaguya2/blob/master/src/main.rs)
- Ruby: [https://github.com/mozamimy/kaguya/blob/master/lib/kaguya/cli.rb](https://github.com/mozamimy/kaguya/blob/master/lib/kaguya/cli.rb)

<p>
{{ embed_code "/2017/04/19/main.rs" }}
</p>

処理系のエントリーポイントになるコードです。書いてあるとおりですね。

- BF のソースコードをファイルから読む
- `Parser` で{字句,構文}解析をして AST を作る
- `Compiler` で AST をコンパイルしてバイトコード的なもの (iseq) を作る
- `VirtualMachine` で iseq を実行する

iseq という名前でピンと来た方もいらっしゃると思いますが、cruby の影響を多分に受けています (二度目)。

### AST

- Rust: [https://github.com/mozamimy/kaguya2/blob/master/src/ast.rs](https://github.com/mozamimy/kaguya2/blob/master/src/ast.rs)
- Ruby: [https://github.com/mozamimy/kaguya/blob/master/lib/kaguya/ast/node.rb](https://github.com/mozamimy/kaguya/blob/master/lib/kaguya/ast/node.rb)

**これが一番つらかった。**

もう一度いいます。

**これが一番つらかった。**

以下のコードは Rust 版。

<p>
{{ embed_code "/2017/04/19/node.rs" }}
</p>

以下のコードは Ruby 版。

<p>
{{ embed_code "/2017/04/19/node.rb" }}
</p>

これは Rust での実装と Ruby での実装が全く違っています。
Ruby 版は非常にナイーブな実装ですね。`Node` クラスのオブジェクトが親 (parent) と子供 (children) を持つという、誰もが思いつく簡単な実装です。
Ruby には GC があるのでそのような実装でも、不要になったオブジェクトはガベージコレクタによってお掃除されるので大丈夫です。

Rust には GC がないので、データ構造が循環してしまうと途端につらくなります。リークが発生するようなコードになっていると、所有権やライフタイムの仕組みによってコンパイラがちゃんと叱って守ってくれます。
Rc や RefCell といったスマートポインタを使う実装もあるそうですが、ここではいわゆる アリーナと呼ばれる概念を使って実装しました。

参考: [Rust でグラフ構造や木構造を作る - 右上➚](http://agtn.hatenablog.com/entry/2017/01/16/151745)

`NodeArena` が `alloc` 関数によって生成した `Node` をベクタに保持し、ノードを参照したり値を書き換えたいときは `get` 関数や `get_mut` 関数が `Node` の持つ `node_id` を使ってミュータブル/イミュータブルオブジェクトをとってくる感じです。

実装は簡単なのですが、やはりいくつか問題があり、

- 間接的に参照することになってだるい
- ノードが頻繁に追加されたり削除されたりすると `NodeArena` にゴミが残る

今回は AST を作ってしまえばオシマイなので 2 コ目の欠点は大した問題にならないのですが、`NodeArena` を適切にメンテするのは結構大変だと思います。

「ゴミが残る」というフレーズでピンときたかもいるかもしれませんが、要するに GC がやっていることを人間が実装しないといけなくなるのですよ。 **Rust とはなんだったのか。**

`accept` 関数は、いわゆる [Visitor パターン](https://ja.wikipedia.org/wiki/Visitor_%E3%83%91%E3%82%BF%E3%83%BC%E3%83%B3) を使ってパーサ側にアルゴリズムを持たせるために使う関数です。

## パーサ

- Rust: [https://github.com/mozamimy/kaguya2/blob/master/src/parser.rs](https://github.com/mozamimy/kaguya2/blob/master/src/parser.rs)
- Ruby: [https://github.com/mozamimy/kaguya/blob/master/lib/kaguya/parser.rb](https://github.com/mozamimy/kaguya/blob/master/lib/kaguya/parser.rb)

<p>
{{ embed_code "/2017/04/19/parser.rs" }}
</p>

これはそこまで難しいコードではないでしょう。

`input` に文字列を受け取り、それを一文字ずつパターンマッチし、valid な文字なら AST のノードを生成し、invalid な文字なら `panic!` して処理系が死にます。

`context_level` は `[` と `]` の対応をとるためのもので、ちゃんと対応していないと最終的に `0` にならないので、構文がおかしいことを検出して `panic!` できます。

たとえば、BF の `++-->[-<[++]]` のようなコードを解析すると、以下のような AST が得られます。

```
・[Root]
┣・[Increment]
┣・[Increment]
┣・[Decrement]
┣・[Decrement]
┣・[Forward]
┗・[While]
　・[Decrement]
　┣・[Backward]
　┗・[While]
　　┣・[Increment]
　　┗・[Increment]
```

## 仮想マシン

- Rust: [https://github.com/mozamimy/kaguya2/blob/master/src/virtual_machine.rs](https://github.com/mozamimy/kaguya2/blob/master/src/virtual_machine.rs)
- Ruby: [https://github.com/mozamimy/kaguya/blob/master/lib/kaguya/vm.rb](https://github.com/mozamimy/kaguya/blob/master/lib/kaguya/vm.rb)

<p>
{{ embed_code "/2017/04/19/virtual_machine.rs" }}
</p>

仮想マシンは記憶領域として `left_stack` と `right_stack` という 2 コのスタックを持ち、`pc` (プログラムカウンタ) に現在実行中の命令の番地を持っています。

また、仮想マシンは `InstructionType` に示したように、9 コの命令を解釈します。`BranchIfZero` と `BranchUnlessZero` 以外は、BF のそれぞれの `<` や `+` といった文字に対応しています。
`BranchIfZero` は、スタックから pop した値が 0 なら `pc + 引数` の番地に `pc` をセットし、`BranchUnlessZero` は pop した値が 0 でないなら `pc + 引数` の番地に `pc` をセットします。
つまり、引数の値を使って相対的にジャンプします。

`run` 関数では `pc` の指す番地から `Instruction` を取り出し、それを実行する動作を無限に繰り返します。
`execute` 関数では `instruction_type` でパターンマッチして、それぞれの命令を実行します。

`BranchIfZero` や `Leave` といった命名でピンときたかもしれませんが、cruby の YARV の影響を多分に受けています (三度目)。

スタックを 2 コ用意しているのは、BF で `<` (ポインタをデクリメントする) をスタックマシン (push と pop しかできない) でエミュレートするためです。
`>` の場合は単にスタックに 0 を積めばいいのですが、`<` の場合、ポインタをデクリメントするために値を pop してしまうと、そのまま pop された値は消えてしまいます。
そこで、`right_stack` に pop した値を積むことで、データが失われないようにします。

たとえば、BF のデータ配列が以下のようになっているとき、

```
         ↓
[0][1][1][2][1][3]
```

スタックマシン上ではこうなってます(右にいくほど上)。

```
                      ↓
left_stack:  [0][1][1][2]
                ↓
right_stack: [3][1]
```

余談ですが、地味に辛かったのが `Input` の実装です。Ruby では `STDIN.getc` しているのですが、Rust の標準ライブラリには相当するものがありません。
いろいろ考えた挙句、[libc crate](https://crates.io/crates/libc) を見つけたのでネイティブの `getchar()` を雑に使うことでクリアしました..。

## コンパイラ

- Rust: [https://github.com/mozamimy/kaguya2/blob/master/src/compiler.rs](https://github.com/mozamimy/kaguya2/blob/master/src/compiler.rs)
- Ruby: [https://github.com/mozamimy/kaguya/blob/master/lib/kaguya/compiler.rb](https://github.com/mozamimy/kaguya/blob/master/lib/kaguya/compiler.rb)

<p>
{{ embed_code "/2017/04/19/compiler.rs" }}
</p>

コンパイラでは、AST を順に辿りながら、VM の命令列 `iseq` を生成します。

`White` ノードは必ず子を持つので、子に対して命令列を生成し、`sub_iseq` にバインドします。
そして、`sub_iseq` の長さを利用して `BranchIfZero` と `BranchUnlessZero` の引数に設定する値を決めます。

たとえば、 `>[+-]-` のような BF コードがあると、AST に変換されたのち最終的に以下のような命令列が生成されます。

```
0: Increment, NULL
1: BranchIfZero, 4
2: Increment, NULL
3: Decrement, NULL
4: BranchUnlessZero, -2
5: Decrement, NULl
6: Leave, NULL
```

あとは、コンパイラで生成したこのような命令列を `VirtualMachine` で `run` すれば、BF プログラムが元気に走り出します！

## まとめ

Rust は学習曲線が急峻だと言われますが、思ったほど難しいという感覚はなかったです。
公式ドキュメントの [The Rust Programming Language](https://doc.rust-lang.org/book/) が驚くほど親切なので、地道に写経すればだいたい理解できます (Effective に書けるかどうかは別として)。

木構造の実装の際は、リークするようなコードになっているとコンパイラが叱ってくれる上、コンパイラのエラーメッセージがすごく親切 (これはもう本当に!) で非常に便利でした。

この活動を通して Rust でそこそこなんでも書ける気がしてきたので、積極的に使っていきたいなあという気持ちです。

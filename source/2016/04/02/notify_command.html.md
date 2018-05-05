---
title: say コマンドでつくる簡単なデスクトップ通知
date: 2016-04-02
tags: bash
---

OS X に付属の `say` コマンドを利用すると、任意の文字列を計算機にしゃべらせることができます。`say` コマンドと OS X のデスクトップ通知、bash の function を組み合わせることで、デスクトップ通知をするためのシンプルなコマンドを作ることができます。

## コード

以下のコード片を、.bashrc などに記述します。

```bash
function notify() {
  osascript -e "display notification \"$1\""

  if [ -n "$TMUX" ]; then
    reattach-to-user-namespace say $1
  else
    say $1
  fi
}
```

`osascript` コマンドを `-e` オプションといっしょに使うと、文字列を AppleScript として実行することができます。ここでは、AppleScript の `display` 関数を使ってデスクトップ通知を発行しています。

続く `if` では、シェルが tmux 上で起動されているかを判定しています。tmux 上では `say` コマンドが正常に動作しないので、[reattach-to-user-namespace](reattach-to-user-namespace) コマンドを使えるようにしておく必要があります。もし tmux を利用していないのであれば、単純に `say` コマンドを呼び出すだけで OK です。

また、OS X の言語設定が英語になっていて、かつ日本語を使いたい場合は、事前に [Kyoko もしくは Otaya を使えるようにしておく](http://itea40.jp/technic/mac-beginners/kyoko-otoya/) 必要があります。

## 利用例

わたしは、時間のかかるコマンドの終了を通知するためによく利用します。

```
$ ruby heavy-process.rb; notify 'スクリプトの実行がおわったよ'
```

以下のスクリーンショットのように、デスクトップ通知とともにコマンドの実行の終了をおしらせしてくれます。かわいい。

![notifyコマンドの実行結果](/2016/04/02/notify_command/finished-script.png)

単純なコマンドとして実行できるので、さまざまなスクリプトの部品として応用できると思います。

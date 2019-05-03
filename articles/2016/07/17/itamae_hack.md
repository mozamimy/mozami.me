---
title: Itamae でレシピとリソースに共通のヘルパメソッドを定義するテクニック
date: 2016-07-17
tags: infra, programming
---

[Itamae](https://github.com/itamae-kitchen/itamae) 使ってますか？

Chef のような Ruby の DSL による気持ちのいい書き心地と、Ansible のようなシンプルさを兼ね備えており、わたしのお気に入りの構成管理ツールです。

## レシピとリソースにヘルパメソッドを追加したい

ある程度 Itamae のレシピが増えてくると、コードを DRY にするために、特定の処理やデータをメソッドとしてくくりだしておいて、各所で使いたくなることがあります。

Itamae は結局 Ruby なので、この目的を達成する方法はいろいろあると思います。この記事では、それなりにキレイと思われる、レシピとリソースに共通のヘルパメソッドを定義する方法を紹介します。

## ソースコードツリー

ファイル構成はこんな感じになります。Itamae スクリプトとして `recipe.rb` を実行したときに、`itamae_helper.rb` を読み込み、`itamae_helper.rb` が `helpers` ディレクトリ以下の .rb ファイルを読みにいきます。

```
・root_dir
┣・helpers
┃┣・common_helper.rb
┃┣・recipe_helper.rb
┃┗・resource_helper.rb
┣・itamae_helper.rb
┗・recipe.rb
```

## itamae_helper.rb

<p>
{{ embed_code "/2016/07/17/itamae_helper.rb" }}
</p>

## helpers

### common_helper.rb

<p>
{{ embed_code "/2016/07/17/common_helper.rb" }}
</p>

### recipe_helper.rb

<p>
{{ embed_code "/2016/07/17/recipe_helper.rb" }}
</p>

### resource_helper.rb

<p>
{{ embed_code "/2016/07/17/resource_helper.rb" }}
</p>

## recipe.rb

<p>
{{ embed_code "/2016/07/17/recipe.rb" }}
</p>

## 解説

ポイントは、

<p>
{{ embed_code "/2016/07/17/point.rb" }}
</p>

の 2 行です。

このように書くことで、コードが recipe として評価されるコンテキストで、`include` を実行し、任意のモジュールをインクルードすることができます。

レシピとリソースで使うようなメソッドは `CommonHelper` に、レシピのみで使うなら `RecipeHelper` に、リソースのみで使うなら `ResourceHelper` に定義すると、メソッドの見える範囲が絞れてベターです。

このテクニック、地味に [usamimi-devenv](https://github.com/mozamimy/usamimi-devenv) (わたしの開発環境の itamae ファイルの置き場所)で利用しているのですが、便利です。

DRY な Itamae でスマートに構成管理をしましょう💓

## 2016-07-18 修正

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">もうModule#includeはsendしなくていい時代ですよ</p>&mdash; k0kubun (@k0kubun) <a href="https://twitter.com/k0kubun/status/754657741952602112">July 17, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

こくぶんさんがボソッと言ってたので、確かに〜と思って紹介したコードを修正しました。

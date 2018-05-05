---
title: ウサギの需要を満たす middleman 向けデプロイツール cheshirecat
date: 2016-03-19
tags: ruby, web, tool
---

## TL; DR

先日、[middleman-blog](https://github.com/middleman/middleman-blog) という gem を使って、GitHub Pages と組み合わせてブログをリニューアルしたという記事を書きました。

middleman-blog を使ってブログを構築すると、基本的にすばらしい体験を得られます。ですが、リポジトリの運用方法によっては、少しデプロイが煩雑になるという問題があり、それを省力化するために [cheshirecat](https://github.com/mozamimy/cheshirecat) という小さい gem を作りました。

## 何が問題なのか

middleman で作った静的ウェブサイトを楽にデプロイするためのツールは、[middleman のデプロイ拡張ツール一覧](https://directory.middlemanapp.com/#/extensions/deployment) で見られるように、用途に合わせてモリモリ開発されています。わたしはナマケモノなので、できる限り楽をしたいと思ってこれらのツールを眺めていたのですが、どれもわたしの需要を満たすものではありませんでした。

[middleman-deploy](https://github.com/middleman-contrib/middleman-deploy) が一番需要を満たせそうだったので試してみたのですが、以下の理由でうまく使いこなせませんでした..

- gem で配布されている安定版が最新版の middleman に対応していない
- ソースとビルド後のファイルが同じリポジトリで管理されていることが前提の設計になっている

1 点目は Gemfile で直接リポジトリを参照すれば解決できるのですが、特に 2 点目の理由がクリティカルでした。

## ソースとビルド後のファイルを別に管理したい

GitHub Pages で`mozamimy.github.io` に公開したい場合、`mozamimy.github.io` または `mozamimy.github.com` という名前の public リポジトリを作り、master ブランチにビルド後のファイルを push する必要があります。なので、middleman を使ってブログを構築する場合には、以下の 2 つのやり方を思いつきます。

- `mozamimy.github.io` リポジトリの master ブランチにはビルド後のファイルのみを置き、別のブランチにソースを置く
- `mozamimy.github.io` リポジトリはビルド後のファイルを置くためだけに利用し、ソースは別のリポジトリ（たとえば `source.mozamimy.github.io` など）で管理する

1 番目の方法は非常にアレに感じるので 2 番目の方法をとっているのですが、こうするとデプロイで困ることになります。

## cheshirecat

というわけで、[cheshirecat](https://github.com/mozamimy/cheshirecat) という小さい gem を作りました。

middleman のプラグインとして実装することも考えたのですが、達成したい目的がしょぼいこととメンテナンスコストの観点から、ふつうの Ruby スクリプトとして実装することにしました。

## cheshirecat を使ってらくらくデプロイ

Gemfile に以下のように書いて `bundle install` すると `cheshirecat` コマンドが使えるようになり、簡単に GitHub Pages にブログをデプロイすることができるようになります。

```ruby
gem 'cheshirecat'
```

デプロイするときは、middleman のソースのリポジトリで、以下のようなコマンドを実行します（長いですが 1 行です）。

```
$ (bundle exec) cheshirecat ./build 'git@github.com:mozamimy/mozamimy.github.com.git'
  master 'Moza USANE', 'mozamimy@quellencode.org'
```

`cheshirecat` コマンドの引数は以下のようになっています。

- 1 個目: ビルド後のファイルが入ったディレクトリ
- 2 個目: ビルド後のファイルを置くリモートリポジトリ
- 3 個目: デプロイ先のブランチ
- 4 個目: commit に含める author の名前
- 5 個目: commit に含める author のメールアドレス

デプロイ先のリポジトリに force push するので、用法用量を守って、くれぐれもお取り扱いにはご注意ください。

## さらにやりたいこと

`cheshirecat` を使えば手元で簡単デプロイできるのですが、どうせなら Travis CI と組み合わせて、ソースリポジトリの master ブランチに merge した瞬間にデプロイされるところまでやりたいです。Travis CI との連携はうまくやる方法がまとまったら、また記事に起こしたいと思います。

では、よきブログライフを🐇

---
title: LGTM 用の gif 画像をパッと探してポッと貼れるアプリを Electron で作ってみました
date: 2016-03-27
tags: web, tool
---

<img src='/2016/03/27/selemene-release/selemene.gif' style='width: 400px;'>

## Node.js & Electron デビューしたかった

最近、JavaScript 周りのフロントエンドがアツいですよね。

仲のいい人たちがフロントエンドで盛り上がっているので、彼らが何を言ってるのかを理解できるくらいには、フロントエンドを嗜んでおきたいという気持ちになりました。

思えばわたしの JavaScript 観は 2000 年代で止まっていて、業務でも jQuery を採用しているコードを触っているのます。なので、そろそろ生 DOM をゴリゴリいじくりたおすのとは違うパラダイムを学んでみよう、というのがことの発端です。

そして、どうせ JavaScript 周辺の知識を身につけるなら、すぐに何かを作って役立てていきたい。となると、やっぱり Electron でしょ！ということで Electron を使ってちょっとしたアプリを作ってみました。

## LGTM 用のアニメ gif を探して管理したい

LGTM 用のアニメ gif を検索して簡単に markdown 形式で貼り付けられるようなアプリを前々から欲しいと思っていました。[Giphy](http://giphy.com/) という gif 画像検索サイトの API を使えば作るのも簡単そうだったので実装しました。

[Selemene (GitHub)](https://github.com/mozamimy/selemene) という名前で公開しています。Linux 用と Windows 用のバイナリも配布していますが、動作チェックしておりません。あしからず。

## Selemene

適当に vim っぽく操作できます。

### キーバインディング

- i: 検索窓にフォーカス
- j: 下の画像に移動
- k: 上の画像に移動
- y: markdown 用にクリップボードにコピー
- Esc: 検索窓からフォーカスを外す
- Enter: 検索

## 今後の予定

Electron の勘所をさぐりながら、とりあえず使えるレベルまでの実装なので、いろいろやりたいことが山積みです。

- アイコンを作る
- ビルドの自動化
- ES6
- React
- Redux
- Slim
- Sass
- Test & Travis CI

ビルドの自動化や Travis CI で継続的インテグレーションを目指そうと思うと、`npm` コマンドをはじめとする、JavaScript 流のパッケージの扱い方など、エコシステム全体を知る必要があります。

また、ES6 や React.js、Redux といったフレームワークをきちんと学んで、モダンなフロントエンド開発を学んでいきたいです。あと、生 HTML や生 CSS がつらいことを再認識したので、Slim や Sass を使えるようにしたい。

## 所感

Rails のような「設定より規約」という文化がないので、良くも悪くもフリーダムだと感じました。

実装時は、主に [@Linda_pp](https://twitter.com/Linda_pp) さんの [Shiba](https://github.com/rhysd/Shiba) や [@k0kubun](https://twitter.com/k0kubun) さんの [Nocturn](https://github.com/k0kubun/Nocturn) を参考にしていました。Shiba ではタスクの多くを Rakefile に依存しているのに対し、Nocturn では npm script や gulpfile.js と JavaScript でまかなっているなど、個性が出ていておもしろいです。

## まとめ

Electron を使えばそれっぽいものが一瞬で作れて楽しい。

---
title: ブログをリニューアルしました
date: 2016-03-13
tags: 雑記
---

## TL; DR

- Tumblr が使いにくくなってきたので
- ナウくてべんりな Middleman で
- ブログを構築しました

## 目覚めたらブログが見れなくなっていた

これまで Tumblr を使って、[http://blog.quellencode.org/](http://blog.quellencode.org/) という URL で細々と技術ブログを書いていたのですが、ある日突然ページがロードできなくなって、どうしたものかと困りました。

大昔に投稿画面の UI が変わってから、技術ブログをゴリゴリ書くのに不便になってしまったこともあり、重い腰を上げてブログを移行することにしました。

## どこでブログを書くか?

いい世の中になったもので、今ではブログを書くためのプラットフォームが山ほどあります。どれがいいかなーと吟味して、以下の 5 個に絞りました。

- [Wordpress](https://wordpress.com/)
- [Qiita](http://qiita.com/)
- [はてなブログ](http://hatenablog.com/)
- [Jekyll](https://jekyllrb.com/)
- [Middleman](https://middlemanapp.com/)

Wordpress は、セットアップや環境構築がめんどくさそうなのではじめに候補から外しました。

Qiita のアカウントを塩漬けにしているので Qiita も候補に上げたのですが、書ける内容が絞られるので却下しました。

周囲で使っている人の多いはてなブログもいいかなと思ったのですが、あとに挙げる静的サイトジェネレータの利点に押されて却下しました。

残る Jekyll や Middleman ですが、これらは少し毛色が違います。ローカルでゴリゴリ書いた Markdown から、ブログっぽい構造になるように HTML を生成してくれるツールです。

結局、普段親しんでいる Rails の知恵が応用できる Middleman を採用し、GitHub Pages でホストすることにしました。

## Middleman どう?

Middleman をベースにブログを構築する場合、[middleman-blog](https://github.com/middleman/middleman-blog) を利用します。

以前からブログの原稿は Markdown で書いて git で管理していたので、ブログのデザイン、設定その他もろもろを、記事と一緒にワンストップで管理できるのは最高の体験でした。

### いい

- vim と Markdown で書ける
- ページのロードがはやい
- 広告がない
- デザインを好きなようにできる

### わるい

- 使い物になるまでがそこそこめんどかった
- デプロイがめんどい

デプロイがめんどいのは、ビルドした HTML ファイルをあたたかみのある手オペでリポジトリに push しているからです。

詳細は省きますが、Middleman でビルドする前のソースと、GitHub Pages 用のリポジトリを分けていると、[middleman-deploy](https://github.com/middleman-contrib/middleman-deploy) が思ったように機能してくれないのです..

これに関しては適当にスクリプトを書いて自動化する予定です。

## おわりに

このブログを構築するためのソースは、[GitHub リポジトリ (source.mozamimy.github.io)](https://github.com/mozamimy/source.mozamimy.github.io) に置いてあります。雑に作ったのでリファクタリングすべき部分がたくさんありますが、これから Middleman でブログを構築したいときの参考になると思います。どうぞご利用ください。

## しゅくだい

- レイアウトと CSS 周りをきれいにする
- Disqus でコメント欄をつける
- シェアボタンをつける
- 前のブログの有用そうな記事をポートする

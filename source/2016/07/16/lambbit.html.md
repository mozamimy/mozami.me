---
title: Node.js と AWS (S3・Lambda・SES）を使って CLI アップローダを作ってみた
date: 2016-07-16
tags: infra, AWS, tool
---

![Architecture](/2016/07/16/lambbit/lambbit_architecture.png)

## AWS の API であそぶ

ちかごろ、業務で本格的に AWS と向き合う機会が増えてきました。AWS の API を使いこなしていろいろなものが作れるようになりたいなと思ったので、前から遊んでみたかった Lambda を使って、CLI で使えるファイルアップローダを作ってみました。

## ファイルの受け渡しがめんどくさい問題

ファイルアップローダは巷にたくさんありますが、たいていがブラウザベースで、わたしにとって使いやすいものではありません。CLI でシュッとファイルをアップロードしてメール送れたらな〜と常々思っていたのですが、ある日天啓が。

**「AWS の API の勉強がてら、S3 と Lambda と SES を組み合わせたらできるのでは!?」**

その勢いで Lambbit というツールを作りました。Lambda でサポートされている言語は、Python・JavaScript (Node.js)・Java の 3 択になるのですが、宗教上の理由から JavaScript を選択しました。Node.js の心得があってよかった。

## リポジトリ

リポジトリはふたつにわかれています。CLI クライアントと Lambda にアップロードするスクリプトです。

- [lambbit-client](https://github.com/mozamimy/lambbit-client)
- [lambbit-lambda](https://github.com/mozamimy/lambbit-lambda)

README.md に書いてあるとおりにセットアップすれば使えるようになります。AWS を直接使うので少々面倒ですが..

## 簡単な使い方としくみ

概観は記事冒頭の画像を見てください。

ターミナルから以下のようなコマンドをたたくと、ファイルが S3 にアップロードされます。

```
$ lambbit-client \
  --bucket your_bucket_name \
  --file /path/to/file/to/upload \
  --to receiver@example.com \
  --from sender@example.com \
  --subject 'Gift for you!' \
  --body 'Check it out :D' \
  --expire 300
```

オプションで指定したバケットにファイルがアップロードされ、メールアドレスやメール本文、有効期限がメタデータとしてオブジェクトに記録されます。

Lambda スクリプトではそれらのメタデータを読みとり、メールを送信します。また、`--expire` に指定した秒数がたつと、オブジェクトの有効期限が切れてダウンロードできなくなります。

## 既知の問題点

サブジェクトとメール本文に日本語を使いたいところですが、S3 にアップロードするときに、なぜか 403 が返ってきて悲しい気持ちになります.. メタデータは ASCII 文字しかダメなのかもしれません。

## まとめ

AWS の API を使うと、いろいろ遊べて楽しいです。Web サーバなどを使うアップロードシステムを EC2 や他社の VPS で運用すると割高になりますが、Lambda を使えばとっても安く運用できてお財布にも優しいですね。

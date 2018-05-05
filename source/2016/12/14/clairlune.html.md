---
title: ネイティブ npm モジュールをビルドして Lambda で使いやすくする Clairlune の紹介
date: 2016-12-14
tags: infra, AWS, tool
---

この記事は、[Serverless Advent Calendar 2016](http://qiita.com/advent-calendar/2016/serverless) の 15 日目の記事です。

Node.js で Lambda function を書くときに、地味に困るのがネイティブバイナリのビルドが必要な npm モジュールを利用する場合です。何も考えずに手元でビルドして zip で固めてアップロードしても、Lambda が実行される環境でそのバイナリが実行できるとは限りません。

そこで、ビルドとスクリプトのアップロードを助けるツール Clairlune を作りました。

[https://github.com/mozamimy/clairlune](https://github.com/mozamimy/clairlune)

Clairlune は、コマンドラインツールまたは Rake タスクの中で使われることを想定しています。

## しくみ

Clairlune の本体は Lambda function で、以下のようなデータの流れで動きます。

- Lambda function の package.json そのものを引数として Clairlune の index.js を起動する。
- 起動したスクリプトが、Lambda 上の一時ディレクトリでモジュールをビルドする。
- ビルド後の npm\_modules を zip で固めて S3 に置く。
- 指定したディレクトリに zip で固めた npm\_modules を S3 からダウンロードしてくる。

この一連の動作は自動で行われます。
最終的に手元にダウンロードされた npm\_modules をあなたの Lambda function に含めて Lambda にアップロードすることで、Lambda 上でネイティブ npm モジュールを使う function が実行できます。


## 使い方

最初に、Clairlune に含まれている clairlune/lambda/clairlune/ を Lambda にアップロードして function が動く状態にしておきます。

また、以下のように `gem` コマンドで clairlune をインストールしておきます。Ruby が必要です。

```
$ gem install clairlune
```

次に、Lambda function の package.json に以下のように Clairlune で使うための情報を埋め込みます。

ポイントは `clairlune` の部分で、`bucket` に npm\_modules を zip で固めたファイルを一時的に置いておくバケットを指定し、`key` にはそのオブジェクトのキーを指定します。

```javascript
{
  "name": "my-awesome-function",
  "private": true,
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "aws-sdk": "^2.6.0",
    "node-uuid": "^1.4.7",
    "@google-cloud/storage": "^0.1.1"
  },
  "engines": {
    "node": "4.3.2"
  },
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "mozamimy (Moza USANE) <mozamimy@quellencode.org>",
  "clairlune": {
    "bucket": "my-awesome-bucket",
    "key": "node_modules.zip"
  }
}
```

### Ruby コード上で実行する

Lambda function をアップロードするのを Rake タスクなどで自動化している場合、以下のように `Clairlune::Builder` を使うと便利です。

```ruby
require 'clairlune/builder'

builder = Clairlune::Builder.new(
  bucket: 'my-awesome-bucket',
  key: 'node_modules.zip',
  package_json: '/path/to/package.json',
  function_name: 'clairlune',
  dest: '/path/to/node_modules.zip',
)
builder.performe
```

各オプションの意味は以下のとおりです。

- `bucket`: npm\_modules を zip で固めたファイルを一時的に置く S3 bucket
- `key`: npm\_modules を zip で固めたファイルのオブジェクトのキー
- `package_json`: 対象の Lambda function の package.json
- `function_name`: Clairlune で使う Lambda function の名前
- `dest`: zip で固められた npm\_modules のダウンロード先

このコードを実行することで、`dest` で指定したパスに npm\_modules を含む zip ファイルがダウンロードされます。

### コマンドラインツールとして実行する

Ruby 以外の手段で Lambda function のアップロードを自動化していたり、手元で気軽に実行したいときは、コマンドラインツールとして利用できます。
実行例は以下の通り。

```
$ clairlune --bucket my-awesome-bucket --key clairlune/node_modules.zip --package-json ~/lambda/my-awesome-function/package.json --function-name clairlune --dest node_modules.zip
```

```
$ clairlune --help
Usage: clairlune [options]
        --bucket BUCKET
        --key KEY
        --package-json /path/to/package.json
        --function-name NAME
        --dest /path/to/node_modules.zip
        --loglevel (fatal|error|warn|info|debug)
        --version
```

各オプションは、Ruby のコードとして使う場合のオプションと同様です。

## さいごに

効果的に利用できる場面は限られてきますが、地味に便利だと思うのでどうぞご利用ください。

明日は [@nekoruri](http://qiita.com/nekoruri) さんの番です! ステキなサーバーレスの記事、楽しみにしております🐰

---
title: Travis CI の docker image をローカルでビョーンとしてみました
date: 2016-03-21
tags: infra
---

![Docker](/images/2016/03/21/travis-runner/docker.png)  
（docker くじらくんかわいい💓）

## TL; DR

ちょっと複雑なビルドプロセスを Travis CI に任せようとしたときに、いちいち新しいブランチを作って merge して.. みたいな繰り返しがイヤになってきました。

Travis CI で使われている docker image が公開されているので、それを使ってビルドプロセスの検証をちょっと楽にしたときのメモ書きです。

## まえおき

.travis.yml をゴリゴリいじっているときに、Twitter にそれがつらい旨を書き込んだら、ソフトウェアをつくる犬の [@Linda_pp](https://twitter.com/Linda_pp) さんがオトク情報を教えてくれました。

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr"><a href="https://twitter.com/mozamimy">@mozamimy</a> 公式に(?) Docker image 配布してるみたいですよ📦 <a href="https://t.co/oS6vlsHg9I">https://t.co/oS6vlsHg9I</a></p>&mdash; ドッグ (@Linda_pp) <a href="https://twitter.com/Linda_pp/status/710765454843707393">March 18, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

ありがたや〜と思いながら、とりあえず `docker run` してみたものの、どうやってテストを走らせるのか謎だったので、いろいろ試してみることにしました。

## travis-build

最終的に、Travis CI 公式の [travis-build](https://github.com/travis-ci/travis-build) を使えば、.travis.yml から Travis CI で使われているビルドスクリプトを生成できるということを知り、[Dockerfile を書いてみました](https://github.com/mozamimy/travis-runner)。

<p>
{{ embed_code "/2016/03/21/Dockerfile" }}
</p>

Ruby 用のコンテナでしか試していませんが、proof of concept として GitHub にもおいてあるので ([travis-runner](https://github.com/mozamimy/travis-runner))、煮るなり焼くなりおすきにどうぞ。

## 使い方

基本的には GitHub の README.md に書いてあるとおりです。環境変数の設定箇所を自分のプロジェクトに合わせて変更して、適当に `docker build` して、コンテナ内に生成された `build.sh` というビルドスクリプトを `travis` ユーザでキックすればテストが走り始めます。

## 既知の問題点

### 複数の Ruby バージョンを扱えない

.travis.yml 中で、以下のように複数の Ruby バージョンを指定すると、ヘンなビルドスクリプトが出てきます。

<p>
{{ embed_code "/2016/03/21/travis-runner-01.yml" }}
</p>

以下のように、単一のバージョンを指定すると大丈夫です。

<p>
{{ embed_code "/2016/03/21/travis-runner-02.yml" }}
</p>

### リポジトリを pull してくるときのブランチ指定がおかしい

生成されたビルドスクリプト中に対象のプロジェクトを `git pull` する箇所があるのですが、なぜか `--branch=''` という引数がついていて、実行したときにエラーになるので汚い hack を入れています。コードは追ってません..

## まとめ

とりあえずビョーンできたので満足です。Ruby 以外のコンテナではどうなのか、とか、もっといいやり方を発見・知っている方がいれば、ぜひ教えてほしいです🐇

---
title: Salmon v0.5.0 をリリースしました
date: 2019-06-23
tags: programming
---

<img src="/images/2019/06/23/kakinohazushi.png" style="width: 400px;">

ゴールデンウィークにワーッと作って、以降もちまちまと改善を進めている Salmon ですが、v0.5.0 をリリースしました。

[https://github.com/mozamimy/salmon/releases/tag/v0.5.0](https://github.com/mozamimy/salmon/releases/tag/v0.5.0)

ちなみに上の画像は、[いらすとやの柿の葉寿司のイラスト](https://www.irasutoya.com/2014/11/blog-post_63.html)です。地元が奈良県ということもあり、柿の葉寿司大好きなのですよね。鮭も鯖も同じくらい好きです。お土産としては頭一つ抜けているので、奈良に行ってから東京に帰るときにお土産にしたいのですが、日持ちしないのが玉にきず。なので、新幹線の中でモグモグ食べることが多いです。

## salmon init コマンドでプロジェクトの雛形を生成できるようになりました

前から実装しようしようと思っててやってなかったのですが、`salmon init nanika` という感じのコマンドを打つとプロジェクトを初期化できる機能をようやく実装しました。いわゆる `rails new` や `cargo init` のような役割のコマンドですね。

```
$ salmon init usagi
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /articles/2019/06/23/example.md
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /codes/2019/06/23/example.rb
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /layouts/article.hbs
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /layouts/index.hbs
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /layouts/page.hbs
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /layouts/rss.hbs
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /layouts/tag.hbs
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /layouts/year.hbs
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /pages/example.md
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /partials/header.hbs
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /partials/menu.hbs
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /resources/images/sushi_salmon.png
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /resources/stylesheets/layout.sass
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /salmon.yaml
[2019-06-23T09:28:02Z INFO  salmon::initializer] Writing /docker-compose.yaml
[2019-06-23T09:28:02Z INFO  salmon::initializer] Your new Salmon project has been initialized!
[2019-06-23T09:28:02Z INFO  salmon::initializer] Now you can build with `salmon build` command after moved the pr
oject directory.
[2019-06-23T09:28:02Z INFO  salmon::initializer] Execute `docker-compose up nginx` if you want to open your site
in http://localhost:10080/.
```

のような感じで、必要最低限のファイルが一式生成されるので、あとは適宜作りたいサイトに合わせて内容を編集し、`salmon build` コマンドを打てば build ディレクトリが作られて、そこに HTML や CSS などが生成されます。

おせっかいな気もしますが、docker-compose.yaml もついてくるので、ビルドしたあとに `docker-compose up nginx` のような感じで NGINX を立ち上げれば、https://localhost:10080/ からすぐにウェブブラウザで内容を確認することができます。本当は Salmon にウェブサーバを組み込んでカッコよくオートリロードさせたいなあという気持ちがあるのですが、結構大変なので後回しになっています..。

ちなみに、v0.4.0 でしれっと `salmon new` というコマンドも実装していて、以下のように新しい記事の Markdown ファイルやディレクトリをシュッと作り、記事を書き始めることができるようになっています。

```
$ salmon new awesome_article
[2019-06-02T08:10:16Z INFO  salmon::template_generator] Created a directory "./articles/2019/06/02"
[2019-06-02T08:10:16Z INFO  salmon::template_generator] Wrote an article template to "./articles/2019/06/02/awesome_article.md"
[2019-06-02T08:10:16Z INFO  salmon::template_generator] Created a directory "./codes/2019/06/02"
[2019-06-02T08:10:16Z INFO  salmon::template_generator] Created a directory "./resources/images/2019/06/02"
```

## Salmon のこれから

ざっと以下のような機能がほしいな〜という気持ちはあるのですが、普通にブログを作る分にはだいたい満足していて Salmon の改善以外にもやりたいことがいっぱいなので、ぼちぼち進めていく感じになると思います。

- ビルド時にリンク先のサイトの OGP を取得してリッチなリンクを生成する view のヘルパ関数
    - 仮で linkgen と呼んでいる機能です
- 組み込みのウェブサーバと自動リロード

あとはドキュメントが🈚️に等しいので、ぼちぼちちゃんと書いていきたいなという気持ちもあります。自分でもヘルパ関数などの使い方を忘れちゃうこともあるので...。

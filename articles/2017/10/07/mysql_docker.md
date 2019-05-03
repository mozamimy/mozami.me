---
title: Docker で唐突に MySQL 8.0 を試したくなったときにシュッと環境を用意するメモ
date: 2017-10-07
tags: middleware
---

MySQL の運用をしていると、唐突に MySQL 8.0 を触りたくなる瞬間があると思います。

実際、わたしもたまに触りたくなって適当に Docker を使ってコンテナを起動して検証に使うことがあります。その都度ビルドするのも面倒なので.. いつもそのときに使うコマンドなどを忘れるので、メモがてらブログに置いておきます :rabbit:

## 環境

- Arch Linux (2017-10-07 時点)
- Docker version 17.09.0-ce, build afdb6d44a8

## MySQL 8.0 を起動する

```
$ docker pull mysql:8.0.3
$ docker run --name mysql-test -e MYSQL_ROOT_PASSWORD=usamimi -d --rm mysql:8.0.3
```

この時点での最新が 8.0.3 だったので、タグで明示的に指定しています。開発環境なのでパスワードは雑に設定。`-d` でデーモンモードで起動し、用が済んだらコンテナを残しておく必要はないので、`--rm` オプションを指定します。

## MySQL クライアントを使う

開発環境には MySQL クライアントすら入っていないので、サーバとして起動している mysql イメージに含まれているクライアントを使います。

```
$ docker run -it -v $HOME/tmp/mysqltest/:/var/host --link mysql-test:mysql --rm mysql:8.0.3 sh -c 'exec mysql -h mysql -uroot -pusamimi -P3306'
```

ここでのミソは、`-v` オプションを使ってホストのディレクトリをコンテナ側にマウントしているところです。こうしておくと、[MySQL :: Other MySQL Documentation](https://dev.mysql.com/doc/index-other.html) でダウンロードできる検証用の world\_database などを `$HOME/tmp/mysqltest` ディレクトリに置いておいて、起動した MySQL クライアントで `source` することでインポートすることが簡単になります。

## ｵｯｵｯｵｯｵｯ

<iframe width="560" height="315" src="https://www.youtube.com/embed/KkXgU3JCFUE?rel=0" frameborder="0" allowfullscreen></iframe>

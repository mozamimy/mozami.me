---
title: HAProxy 1.6 と 1.7 ではヘルスチェックを設定しないと名前解決が走らない
date: 2018-02-11
tags: infra, docker
---

先日、会社の技術ブログで AWS Lambda を中心としたサーバーレスアーキテクチャーの記事を書いたのですが、思いのほか好評でびっくりしている [@mozamimy](https://twitter.com/mozamimy) です。

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">SAM 便利なので使っていきましょう記事を書きました / サーバーレスなバックアップシステムを AWS SAM を用いてシュッと構築する - クックパッド開発者ブログ <a href="https://t.co/9qbMZborLM">https://t.co/9qbMZborLM</a></p>&mdash; ᕱ⑅ᕱ もざみ (@mozamimy) <a href="https://twitter.com/mozamimy/status/961029511025328128?ref_src=twsrc%5Etfw">February 7, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## HAProxy でハマりがちなポイント

タイトルでオチてますが、書いてある通りです。意外と知られてない割にサービスがダウンするような大事故を起こしかねない挙動なので、ブログにメモしておくことにしました。

1.6 と 1.7 では `check` を書かない場合ヘルスチェックが走らないのでアップストリームに指定した名前が返す IP アドレスが変わった際、それに追従できません。それ以前のバージョンでは調べていません。

```haproxy
global
  uid 0
  gid 0

defaults
  timeout connect 5s
  timeout client 8h
  timeout server 8h
  retries 2

resolvers dns
  nameserver dns1 172.20.64.2:53

listen test
  bind :80
  mode http
  balance roundrobin
  option httpchk GET / HTTP/1.0
  # 下の server ディレクティブは直感的にはよさそうだが check を省略してはダメ
  # server next-balancer upstream:80 resolvers dns
  # ここでは server に指定している項目が 1 コしかないので、
  # fall に適当に大きな数字を指定することで、実質ヘルスチェックを潰す
  # ヘルスチェックのタイミングで DNS 解決が走るので、5 秒ごとに解決されることになる
  server next-balancer upstream:80 check resolvers dns inter 5s fall 17280 weight 100
```

なお、この挙動は 1.8 になってから改善されています。それは Configuration Manual の文言からも読み取れます。

> at run time, HAProxy performs periodically name resolutions for servers requiring DNS resolutions.

[HAProxy version 1.8.4 - Configuration Manual](http://cbonte.github.io/haproxy-dconv/1.8/configuration.html#5.3)

> Bear in mind that DNS resolution is triggered by health checks. This makes health checks mandatory to allow DNS resolution.

[HAProxy version 1.7.10 - Configuration Manual](http://cbonte.github.io/haproxy-dconv/1.7/configuration.html#5.3)

なので、1.8 では `server next-balancer upstream:80 resolvers dns` のようにシンプルに書いて、それ以前のバージョンでは `server next-balancer upstream:80 check resolvers dns inter 5s fall 17280 weight 100` のようにするとよいでしょう。

## この挙動が引き起こす事故

直感的には `check` がない、つまりヘルスチェックを有効にしなくても名前解決が走りそうな気がします.. がそうではありません。

これがどのような場合に困るのかというと、DNS ラウンドロビンでバランスするようなロードバランサを上流に設定したい場合などです。具体的には、AWS の ELB を上流に設定したい場合などです。

この場合、ELB のスケールアウトが走るなどして ELB の FQDN が返す IP アドレスが変わってしまうと、HAProxy がそれに追従できずに以前の IP アドレスにリクエストを送り続けるため、結果的にサービスがダウンするような事故がおこってしまいます。

## HAProxy の挙動を検証する

以下のリポジトリに、HAProxy の挙動を検証するための一連の Docker 環境を用意しました。手元の環境に Docker がインストールされていれば、シュッと挙動を検証することができます。

[mozamimy/haproxy_dns_test: Testing HAproxy behavior for a blog post: TBD](https://github.com/mozamimy/haproxy_dns_test)

検証環境では、以下の docker-compose.yml の内容のように、Dnsmasq を使って雑 DNS サーバを立て、他のコンテナの DNS サーバとして Dnsmasq を指定しています。また、Nginx が動くコンテナを 2 コ用意し、検証時は `upstream` で引ける IP アドレスを更新することで挙動を検証します。

また、HAProxy が動くコンテナを 3 コ (それぞれ 1.6, 1.7, 1.8) 動かし、検証用のスクリプトからそれぞれの HAProxy にアクセスすることで動作を検証します。

```yaml
version: '3'
services:
  # Execute `kill -SIGHUP 1` to reload DNS records
  dnsmasq:
    build:
      context: '.'
      dockerfile: 'Dockerfile.dnsmasq'
    networks:
      haproxy_net:
        ipv4_address: '172.20.64.2'
    extra_hosts:
      - 'upstream:172.20.64.3'
    cap_add:
      - 'NET_ADMIN'

  nginx1:
    build:
      context: '.'
      dockerfile: 'Dockerfile.nginx'
      args:
        TEXT: 'egg.txt'
    networks:
      haproxy_net:
        ipv4_address: '172.20.64.3'
    dns: '172.20.64.2'
  nginx2:
    build:
      context: '.'
      dockerfile: 'Dockerfile.nginx'
      args:
        TEXT: 'chick.txt'
    networks:
      haproxy_net:
        ipv4_address: '172.20.64.4'
    dns: '172.20.64.2'

  haproxy_16:
    build:
      context: '.'
      dockerfile: 'Dockerfile.haproxy.1.6'
    ports:
      - '8016:80'
    depends_on:
      - 'dnsmasq'
      - 'nginx1'
      - 'nginx2'
    networks:
      haproxy_net:
        ipv4_address: '172.20.64.5'
    dns: '172.20.64.2'
    command: ['haproxy', '-f', '/usr/local/etc/haproxy/haproxy.cfg']
  haproxy_17:
    build:
      context: '.'
      dockerfile: 'Dockerfile.haproxy.1.7'
    ports:
      - '8017:80'
    depends_on:
      - 'dnsmasq'
      - 'nginx1'
      - 'nginx2'
    networks:
      haproxy_net:
        ipv4_address: '172.20.64.6'
    dns: '172.20.64.2'
    command: ['haproxy', '-f', '/usr/local/etc/haproxy/haproxy.cfg']
  haproxy_18:
    build:
      context: '.'
      dockerfile: 'Dockerfile.haproxy.1.8'
    ports:
      - '8018:80'
    depends_on:
      - 'dnsmasq'
      - 'nginx1'
      - 'nginx2'
    networks:
      haproxy_net:
        ipv4_address: '172.20.64.7'
    dns: '172.20.64.2'
    command: ['haproxy', '-f', '/usr/local/etc/haproxy/haproxy.cfg']

networks:
  haproxy_net:
    driver: 'bridge'
    ipam:
      config:
        - subnet: '172.20.64.0/24'
```

Dockefile.dnsmasq が Dnsmasq のための Docker イメージです。ベースとして [andyshinn/dnsmasq - Docker Hub](https://hub.docker.com/r/andyshinn/dnsmasq/) を利用し、雑に `/etc/hosts` を書き換えるために Vim をインストールします。

```dockerfile
FROM andyshinn/dnsmasq:2.78

RUN apk update
RUN apk add vim curl
```

Dockefile.nginx が Nginx のための Docker イメージで、nginx1 が上流のときは 🥚 を、nginx2 が上流のときは 🐣 がかえるようにします。**これは、ひよこが「返る」と「孵る」で掛け言葉になっています。**

```dockerfile
FROM nginx:1.13.8-alpine

ARG TEXT
COPY $TEXT /usr/share/nginx/html/test.txt
```

Dockefile.haproxy.#{バージョン番号} が HAProxy のための Docker イメージです。DNS に問い合わせている様子を確認するために、雑にパケットキャプチャするための ngrep をインストールします。

```dockerfile
FROM haproxy:1.8.3

RUN apt-get update && \
    apt-get install -y ngrep

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
```

起動する場合は、上記のリポジトリを手元に clone して、docker-compose を使います。

```
$ docker-compose build
$ docker-compose up
```

全コンテナが立ち上がったら、おもむろに test.sh を起動します。すると、以下のように HAProxy 経由で nginx1 から返ってきたたまごが表示されます。

```sh
#!/bin/bash

while :
do
  echo "1.6: $(curl -sS http://localhost:8016/test.txt), 1.7: $(curl -sS http://localhost:8017/test.txt), 1.8: $(curl -sS http://localhost:8018/test.txt)"
  sleep 1
done
```

```
[18:58:47]mozamimy@P1323-18P13U:haproxy_dns_test (master) (-'x'-).oO(
(ins)> ./test.sh
1.6: 🥚, 1.7: 🥚, 1.8: 🥚
1.6: 🥚, 1.7: 🥚, 1.8: 🥚
1.6: 🥚, 1.7: 🥚, 1.8: 🥚
1.6: 🥚, 1.7: 🥚, 1.8: 🥚
1.6: 🥚, 1.7: 🥚, 1.8: 🥚
1.6: 🥚, 1.7: 🥚, 1.8: 🥚
```

ここで、おもむろに `upstream` が返す IP アドレスを 172.20.64.3 から 172.20.64.4 に切り替えてみましょう。/etc/hosts 中の `172.20.64.3 upstream` を `172.20.64.4 upstream` に書き換え、`SIGHUP` シグナルを dnsmasq に送って設定をリロードします。

```
[19:03:15]mozamimy@P1323-18P13U:haproxy_dns_test (master) (-'x'-).oO(
(ins)> docker exec -it #{ここに dnsmasq のコンテナ ID をいれる} /bin/sh
/ # vim /etc/hosts
/ # kill -SIGHUP 1
```

すると、以下のように 1.8 の場合のみ、たまごが孵ってひよこになります。

```
[18:58:47]mozamimy@P1323-18P13U:haproxy_dns_test (master) (-'x'-).oO(
(ins)> ./test.sh

# :
# : 中略
# :

1.6: 🥚, 1.7: 🥚, 1.8: 🥚
1.6: 🥚, 1.7: 🥚, 1.8: 🥚
1.6: 🥚, 1.7: 🥚, 1.8: 🥚
1.6: 🥚, 1.7: 🥚, 1.8: 🥚
1.6: 🥚, 1.7: 🥚, 1.8: 🥚
1.6: 🥚, 1.7: 🥚, 1.8: 🐣
1.6: 🥚, 1.7: 🥚, 1.8: 🐣
1.6: 🥚, 1.7: 🥚, 1.8: 🐣

# :
# : 中略
# :
```

また、1.6 や 1.7 の場合、以下のようにコンテナ内で ngrep でパケットキャプチャをしても、名前解決が走っていないことがわかります。

```
[19:08:54]mozamimy@P1323-18P13U:haproxy_dns_test (master) (-'x'-).oO(
(ins)> docker exec -t #{ここに 1.6 か 1.7 のコンテナ ID を入れる} ngrep -W byline -q port 53
interface: eth0 (172.20.64.0/255.255.255.0)
filter: (ip or ip6) and ( port 53 )

以降何も出力されない
```

1.8 の場合、以下のように定期的に名前解決が走ってそうな息吹を感じることができます。

```
[19:12:49]mozamimy@P1323-18P13U:haproxy_dns_test (master) (-'x'-).oO(
(ins)> docker exec -t e6dabcdc846c ngrep -W byline -q port 53
interface: eth0 (172.20.64.0/255.255.255.0)
filter: (ip or ip6) and ( port 53 )

U 172.20.64.7:35668 -> 172.20.64.2:53
.............upstream.......)........

U 172.20.64.2:53 -> 172.20.64.7:35668
.............upstream.....

U 172.20.64.7:35668 -> 172.20.64.2:53
.............upstream.......)........

U 172.20.64.2:53 -> 172.20.64.7:35668
.............upstream..................@@...)........
```

## まとめ

意外とハマりがちな HAProxy の名前解決の挙動ですが、1.8 からは直感に即した挙動になっていて便利なので使っていきたいところですね。

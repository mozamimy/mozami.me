---
title: Docker for Mac でホストの特定のポートにつなぐ方法
date: 2016-11-30
tagls: infra, docker
---

[Docker for Mac](https://www.docker.com/products/docker#/mac)、安定してふつうに動くのですが、Linux 用のものとは違って docker0 のような仮想のネットワークアダプタが生えないために、ホスト OS の特定のポートにコンテナからつなぐ、というようなことが直感的にできません。

業務上、AWS の VPC 上にあるサーバの特定のポートに到達できるように SSH トンネルを刺して、ホスト OS に生やしたポートからアクセスできるようにして、コンテナからつなぎにいきたいことがまれによくあるので、これではこまります 🐰 💦

これでずーっと悩んでいたのですが、[公式のドキュメント](https://docs.docker.com/docker-for-mac/networking/#/there-is-no-docker0-bridge-on-macos) にひっそりとワークアラウンドが書かれていました..

以下のように、macOS 上でループバックアダプタに適当にプライベート IP アドレスをあてたらうまくいきます。

```
$ sudo ifconfig lo0 alias 10.233.233.1/24
```

すると、コンテナ上で、

```
root@5e004b2cbf18:/# ping 10.233.233.1
PING 10.233.233.1 (10.233.233.1): 56 data bytes
64 bytes from 10.233.233.1: icmp_seq=0 ttl=37 time=0.411 ms
64 bytes from 10.233.233.1: icmp_seq=1 ttl=37 time=0.543 ms
64 bytes from 10.233.233.1: icmp_seq=2 ttl=37 time=0.778 ms
^C--- 10.233.233.1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.411/0.577/0.778/0.152 ms
root@5e004b2cbf18:/# nc -vz -w3 10.233.233.1 54321
10.233.233.1: inverse host lookup failed: Unknown host
(UNKNOWN) [10.233.233.1] 54321 (?) open
```

のような感じでバッチリ刺さります。やったね ✨

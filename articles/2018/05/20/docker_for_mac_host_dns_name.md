---
title: Docker for Mac でホストの特定のポートにつなぐ方法 (18.03 からのよりよい方法)
date: 2018-05-20
tags: middleware
---

[Docker for Mac](https://www.docker.com/products/docker#/mac) では docker0 のようなブリッジインターフェースがないため、コンテナからホストマシンの特定のポートに刺したいときに、以下の記事に書いたように以前はループバックインターフェースにエイリアス IP アドレスを振る必要がありました。

[Docker for Mac でホストの特定のポートにつなぐ方法](/2016/11/30/docker_for_mac_port.html)

何気なくドキュメントを眺めていたところ、18.03 からは `host.docker.internal` もしくは `gateway.docker.internal` という特殊な DNS 名を使うことができるようになっていました。

[Networking features in Docker for Mac | Docker Documentation](https://docs.docker.com/docker-for-mac/networking/#httphttps-proxy-support)

便利なので使っていきましょう。

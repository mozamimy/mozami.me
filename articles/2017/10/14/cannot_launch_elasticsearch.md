---
title: max virtual memory areas vm.max_map_count [65530] is too low. で Elasticsearch が起動しないとき
date: 2017-10-14
tags: middleware
---

Elasticsearch の起動時に、以下のようなログが出て起動できない場合があります。以下の例では、docker-compose を用いて Elasticsearch 5.5.2 を起動しています。

```
$ sudo docker-compose up es1
WARNING: The k9 variable is not set. Defaulting to a blank string.
Recreating dockercerebro_es1_1 ...
Recreating dockercerebro_es1_1 ... done
Attaching to dockercerebro_es1_1
es1_1      | [2017-10-14T07:56:08,786][INFO ][o.e.n.Node               ] [es1] initializing ...
es1_1      | [2017-10-14T07:56:08,880][INFO ][o.e.e.NodeEnvironment    ] [es1] using [1] data paths, mounts [[/usr/share/elasticsearch/data (/dev/vda2)]], net usable_space [80.9gb], net total_space [97.6gb], spins? [possibly], types [ext4]
es1_1      | [2017-10-14T07:56:08,881][INFO ][o.e.e.NodeEnvironment    ] [es1] heap size [990.7mb], compressed ordinary object pointers [true]
es1_1      | [2017-10-14T07:56:08,883][INFO ][o.e.n.Node               ] [es1] node name [es1], node ID [cmYYcTKrQa6LiHpCftbNKA]
es1_1      | [2017-10-14T07:56:08,883][INFO ][o.e.n.Node               ] [es1] version[5.5.2], pid[1], build[b2f0c09/2017-08-14T12:33:14.154Z], OS[Linux/4.13.5-1-ARCH/amd64], JVM[Oracle Corporation/OpenJDK 64-Bit Server VM/1.8.0_131/25.131-b11]
es1_1      | [2017-10-14T07:56:08,883][INFO ][o.e.n.Node               ] [es1] JVM arguments [-Xms2g, -Xmx2g, -XX:+UseConcMarkSweepGC, -XX:CMSInitiatingOccupancyFraction=75, -XX:+UseCMSInitiatingOccupancyOnly, -XX:+AlwaysPreTouch, -Xss1m, -Djava.awt.headless=true, -Dfile.encoding=UTF-8, -Djna.nosys=true, -Djdk.io.permissionsUseCanonicalPath=true, -Dio.netty.noUnsafe=true, -Dio.netty.noKeySetOptimization=true, -Dio.netty.recycler.maxCapacityPerThread=0, -Dlog4j.shutdownHookEnabled=false, -Dlog4j2.disable.jmx=true, -Dlog4j.skipJansi=true, -XX:+HeapDumpOnOutOfMemoryError, -Xms1g, -Xmx1g, -Des.path.home=/usr/share/elasticsearch]
es1_1      | [2017-10-14T07:56:09,997][INFO ][o.e.p.PluginsService     ] [es1] loaded module [aggs-matrix-stats]
es1_1      | [2017-10-14T07:56:09,998][INFO ][o.e.p.PluginsService     ] [es1] loaded module [ingest-common]
es1_1      | [2017-10-14T07:56:09,998][INFO ][o.e.p.PluginsService     ] [es1] loaded module [lang-expression]
es1_1      | [2017-10-14T07:56:09,998][INFO ][o.e.p.PluginsService     ] [es1] loaded module [lang-groovy]
es1_1      | [2017-10-14T07:56:09,998][INFO ][o.e.p.PluginsService     ] [es1] loaded module [lang-mustache]
es1_1      | [2017-10-14T07:56:09,998][INFO ][o.e.p.PluginsService     ] [es1] loaded module [lang-painless]
es1_1      | [2017-10-14T07:56:09,998][INFO ][o.e.p.PluginsService     ] [es1] loaded module [parent-join]
es1_1      | [2017-10-14T07:56:09,998][INFO ][o.e.p.PluginsService     ] [es1] loaded module [percolator]
es1_1      | [2017-10-14T07:56:09,999][INFO ][o.e.p.PluginsService     ] [es1] loaded module [reindex]
es1_1      | [2017-10-14T07:56:09,999][INFO ][o.e.p.PluginsService     ] [es1] loaded module [transport-netty3]
es1_1      | [2017-10-14T07:56:09,999][INFO ][o.e.p.PluginsService     ] [es1] loaded module [transport-netty4]
es1_1      | [2017-10-14T07:56:09,999][INFO ][o.e.p.PluginsService     ] [es1] no plugins loaded
es1_1      | [2017-10-14T07:56:11,788][INFO ][o.e.d.DiscoveryModule    ] [es1] using discovery type [zen]
es1_1      | [2017-10-14T07:56:12,544][INFO ][o.e.n.Node               ] [es1] initialized
es1_1      | [2017-10-14T07:56:12,545][INFO ][o.e.n.Node               ] [es1] starting ...
es1_1      | [2017-10-14T07:56:12,823][INFO ][o.e.t.TransportService   ] [es1] publish_address {172.19.0.2:9300}, bound_addresses {0.0.0.0:9300}
es1_1      | [2017-10-14T07:56:12,839][INFO ][o.e.b.BootstrapChecks    ] [es1] bound or publishing to a non-loopback or non-link-local address, enforcing bootstrap checks
es1_1      | ERROR: [1] bootstrap checks failed
es1_1      | [1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
es1_1      | [2017-10-14T07:56:12,852][INFO ][o.e.n.Node               ] [es1] stopping ...
es1_1      | [2017-10-14T07:56:12,904][INFO ][o.e.n.Node               ] [es1] stopped
es1_1      | [2017-10-14T07:56:12,904][INFO ][o.e.n.Node               ] [es1] closing ...
es1_1      | [2017-10-14T07:56:12,925][INFO ][o.e.n.Node               ] [es1] closed
dockercerebro_es1_1 exited with code 78
```

## 環境

- Arch Linux (2017-10-14 時点)
- Docker version 17.09.0-ce, build afdb6d44a8
- Elasticsearch 5.5.2

## 対処法

`max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]` というメッセージにしたがって、Linux カーネルパラメータの一つである `vm.max_map_count` を増やしましょう。Arch Linux のデフォルトの設定では、`65530` になっているようです。

カーネルパラメータは [sysctl](https://wiki.archlinux.org/index.php/Sysctl) を用いて設定します。これまで特にチューニングを行っていない場合は、`/etc/sysctl.d/` 以下にファイルが何もないと思うので、適当に `/etc/sysctl.d/99-sysctl.conf` のような感じでファイルを作成し、以下のようにカーネルパラメータを設定します。

```sysctl
vm.max_map_count = 262144
```

設定したパラメータを適用するために、以下のコマンドを実行します。

```
$ sudo sysctl --system
```

これで無事 Elasticsearch が起動できるはず。

## 参考

- [sysctl - ArchWiki](https://wiki.archlinux.org/index.php/Sysctl)
- [elasticsearch:5.0.0 max virtual memory areas vm.max_map_count [65530] likely too low, increase to at least [262144] · Issue #111 · docker-library/elasticsearch](https://github.com/docker-library/elasticsearch/issues/111)

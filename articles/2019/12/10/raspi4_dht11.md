---
title: Raspberry Pi 4 と DHT11 で温湿度を取得するコードをじぶんで書いてみる
date: 2019-12-10
tags: programming
---

つい先日ですが、技適を通過して日本国内で電波を発射できる Raspberry Pi 4 がとうとう買えるようになったということで、スイッチサイエンスから販売されているものを購入しました。

OS は、普段から慣れ親しんでいる Arch Linux の ARM 向けビルドを利用しています。インストールも簡単で、[https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4) の Installation の手順をなぞれば、すぐに Linux で Raspberry Pi の世界が広がります。

手元に microSDHC カードに書き込めるコンピュータが MacBook Pro しかありませんでしたが、VirtualBox の USB サポートを使い、Arch Linux インストール用の ISO イメージを起動し、fdisk などを利用してセットアップしました。

最低限、手積みでやらざるを得ないセットアップの手順は [https://scrapbox.io/mozamimy-public/Raspberry_Pi_4](https://scrapbox.io/mozamimy-public/Raspberry_Pi_4) にまとめてあるので、興味がある方はどうぞ。

さて、前置きはこのくらいにしましょう。Raspberry Pi 4 と DHT11 と呼ばれる温湿度センサを接続して、温湿度を取得するコードを書いてみたので、メモがてらまとめていきたいと思います。

## DHT11 について

[http://akizukidenshi.com/catalog/g/gM-07003/](http://akizukidenshi.com/catalog/g/gM-07003/)

電子工作初心者なので初めて知ったのですが、この DHT11 とよばれる温湿度センサーは、界隈 (?) では割と有名みたいで、Raspberry Pi や Arduino 関連のウェブページでよく取り上げられています。安価で性能はそれなり、手に入りやすくオモチャとしてはお手頃ではないでしょうか。

わたしの場合は、[Amazon で何も考えずに雑に適当な初心者向け電子工作キットを購入した](https://www.amazon.co.jp/gp/product/B07P5LMVN1/ref=ppx_yo_dt_b_asin_title_o03_s01?ie=UTF8&psc=1)結果、数々の素子の中に DHT11 がゴロッと入っていたので遊んでみたという感じです。そもそも、同居人 (人?) である[ルカ](https://scrapbox.io/mozamimy-public/%E3%83%AB%E3%82%AB)のために、Prometheus や Grafana で室温の取得や可視化を行い、異常事態の際にはアラートを上げる仕組みを作りたいというのがモチベーションだったのでちょうどよかったです。

今回、DHT11 から温湿度を取得するためのコードの実装にあたっては、[http://akizukidenshi.com/catalog/g/gM-07003/](http://akizukidenshi.com/catalog/g/gM-07003/) からリンクされている[データシート](http://akizukidenshi.com/download/ds/aosong/DHT11_20180119.pdf)を参考にしました。

[https://github.com/szazo/DHT11_Python](https://github.com/szazo/DHT11_Python) に Python によるライブラリ実装があり、初心者向けの記事ではよく紹介されているようです。今回の自前実装の際にも、出力結果の比較などに利用しました。

## 回路を組む

[データシート](http://akizukidenshi.com/download/ds/aosong/DHT11_20180119.pdf)の Typical circuits のセクションを参考に、以下のような回路を組んでみました。データシートを引用した画像の赤丸の部分を、そのままそっくり真似した感じです。

<img src="/images/2019/12/10/typical_circuits.png" style="width: 600px;">

<img src="/images/2019/12/10/raspi_dht11.png" style="width: 600px;">

実際に配線してみた様子がこれ。↑の回路図と比べて、ジャンプワイヤが刺さっている位置が微妙に違うので注意してください。

<img src="/images/2019/12/10/raspi_dht11_physical.jpg" style="width: 700px;">

手元の DHT11 は基板に据え付けられているタイプで、データシートを信じるならば本来 4 本の足があるはずが 3 本になっており、左から順に GND、DATA、VCC となっていました。なので、データシートの図と左右逆になっていて足が 3 本になっていることに注意してください。また、通電してうまく接続できると、備え付けの LED がピカッと光るようになっているみたいです。

データシートの通り、DATA ピンはプルアップしておきます。4.7kΩの抵抗を使うのがいいみたいですが、手元になかったので適当に 5.1kΩの抵抗で代用しています。今回は GPIO の 2 番ポートをデータの入出力に使うことにしました。

## DHT11 から温湿度を取得するコードを Rust で書く

コードは [https://github.com/mozamimy/raspi-dht11/tree/0.1.0](https://github.com/mozamimy/raspi-dht11/tree/0.1.0) にあります。この記事を書いたあとも順次改良する可能性がありますが、0.1.0 でタグを打った状態のリポジトリにリンクしています。

### x86_64 のマシンで Rust のコードを ARM 用のバイナリをクロスコンパイルする

ただでさえビルドが重い Rust ですが、Raspberry Pi 4 の実機でのビルドは大変時間がかかるので、手元の x86_64 のマシンでターゲットを ARM 向けにしてクロスコンパイルするのが便利です。その際には [Rust: Raspberry Pi (Raspbian) 向けの実行バイナリを手軽に作る](https://kanejaku.org/posts/2019/06/cross-compiling-rust-for-raspi/) の記事を参考にしました。

詳しい解説はリンク先の記事に譲りますが、わたしのリポジトリでは docker コマンドのオプションを書く代わりに、docker-compose を利用し、`docker-compose run --rm --user $(id -u):$(id -g) builder cargo build --target armv7-unknown-linux-gnueabihf` のようにしてビルドできるようにしてみました。

<p>
{{ embed_code "/2019/12/10/docker-compose.yml" }}
<p>

素朴に Docker コンテナの中でプロセスを立ち上げると、target/ ディレクトリ以下に生成される成果物が root ユーザの持ち物になってしまいます。それを防ぐため、`docker-compose run` 時にユーザとグループを明示的に指定し、`/etc/passwd` や `/etc/group` を read only でコンテナ内にマウントすることで、ビルド時の一般ユーザの持ち物となるように工夫しています。また、cargo registry はリポジトリの .cargo-registry ディレクトリをマウントすることで永続化しています。docker-compose で volume を定義し、それをマウントするという方法でも良いでしょう。

依存ライブラリが連れてくる OpenSSL などが絡んでくると ARM 向けにそれをビルドしてリンクする必要も出てくるかもしれませんが、今回はこれだけの単純な準備で実機で動くバイナリを得ることができます。

### Rust で GPIO を制御する

さすがに GPIO を制御するところからスクラッチで書いていると人生がいくつあっても足りないので、ここはライブラリに頼ります。

いくつか使えそうなライブラリがありましたが、フィーリングで [https://github.com/golemparts/rppal](https://github.com/golemparts/rppal) を使ってみました。rppal::gpio module しか使っていませんが、素直でわかりやすいライブラリだと思います。

### タイミングチャートを見ながら実装する

当初、DATA ピンが 1 本しかないのに、どのようにデータを送ってくるのだろうという疑問があったのですが、第 7 セクションの「Serial communication」のあたりや種々のウェブページを読んで納得しました。1 ビットずつシリアルにデータを送ってくるのです。[データシート](http://akizukidenshi.com/download/ds/aosong/DHT11_20180119.pdf)の 7 ページ目から、タイミングチャートを引用します。

<img src="/images/2019/12/10/timing_chart.png" style="width: 700px;">

DHT11 は、ざっくりと以下の 3 ステップでデータを DATA ピンに流します。

- Raspberry Pi 側からデータの要求をする。
    - タイミングチャートの Host send a start signal のあたり
- DHT11 側で、その要求に応答する信号を送る。
    - タイミングチャートの Response signal のあたり
- DHT11 側から 1bit ずつデータが 40bit シリアルに送られてくる。
    - Data "1" bit のあたり

ここで、実装したコードのせておきます。まずは DHT11 を扱うためのモジュール dht11 の実装から。

<p>
{{ embed_code "/2019/12/10/dht11.rs" }}
<p>

dht11 モジュールの利用側のコードは以下のような感じです。

<p>
{{ embed_code "/2019/12/10/main.rs" }}
<p>

#### 利用側のコード

利用側のコードは特に説明するまでもないでしょう。GPIO ポートの番号がハードコーディングされているのはさておき、DHT11 構造体を `new()` 関数で初期化し `read()` 関数で 2 秒おきに値を取得し、無限に標準出力にデータを吐き出しています。`read()` 関数は `Result<dht11::Metric, failure::Error>` を返すので、エラーが起きたときはその旨を標準エラー出力に出します。

#### `read()` 関数をタイミングチャートとともに見る

では、`read()` 関数の中身を、データシートのタイミングチャートとあわせて見ていきましょう。

まずは、`let mut bits: Vec<u8> = Vec::with_capacity(64);` で、送られきてきたビット列を格納するためのベクタを `bits` 変数に束縛しておきます。ただ、ビット列の長さは 40 固定ですし、ベクタを使わずに配列としてスタック領域に確保するほうがいいかな.. とこの記事を書きながら思いました。

次に、`// handshake (?)` というコメントのあとに、忙しく GPIO ポートを high にしたり low にしたりしている箇所があります。これは、[データシート](http://akizukidenshi.com/download/ds/aosong/DHT11_20180119.pdf) 8 ページ目の The host sends a start signal あたりの処理です。タイミングチャートを引用します。

<img src="/images/2019/12/10/host_sends_a_start_signal.png" style="width: 700px;">

いったんポートを high にしたのち、low にして、適当に 25ms 待ったあと、ポートを入力モードに変えています。high → low → high と出力を変えるわけですが、最初の high → low の間に 5μs のディレイを入れてるのは、こうしないとどうも DHT11 側で high → low に変わったことを検出できないようなので、こうしています。

次に、ポートが low になるのを待つ → high になるのを待つ → low になるのを待つ、という動作を `loop` することで実現しています。これは、DHT11 側からのレスポンスを待っている箇所になります。[データシート](http://akizukidenshi.com/download/ds/aosong/DHT11_20180119.pdf) 8 ページ目の Step 3 あたりの記述ですね。タイミングチャートを引用します。

<img src="/images/2019/12/10/resp_signal.png" style="width: 700px;">

そして、続く `for _ in 0..40` が本番です。Raspberry Pi 側の要求に対するレスポンス用の信号を DHT11 から得たのち、40bit の信号を取り込みます。low が 50μs 続いたあとの、high のパルスの長さで 0 と 1 を区別します。[データシート](http://akizukidenshi.com/download/ds/aosong/DHT11_20180119.pdf) 9 ページ目の図ですね。タイミングチャートを引用します。

<img src="/images/2019/12/10/bit_format.png" style="width: 700px;">

パルスの長さは違えど、high → low → high → low → … という順序で信号がやってくるので、`loop` で high になるまで待ち、high の間ループを回し、`conter` 変数をインクリメントすることで high のパルスの長さを判定しています。`THREAHOLD_0_1` よりも大きければ (つまりパルス幅が長ければ) 1 を、そうでなければ 0 を `bits` に push します。

このとき、原因はよくわかっていないのですが、`while self.pin.is_high() { ... }` で無限ループに落ちてしまうことがあり、そうなった場合に復帰するために `THRESHOLD_TIMEOUT` まで `counter` をインクリメントすると、エラーを返して強制的にデータの取得を中断します。

`THREAHOLD_0_1` の決め方がむずかしく、わたしの環境では 0 の場合に 130~170 程度、1 の場合に 400~500 程度になったので、適当に 250 と置いています。この値は環境によって変わりうるし、ループ回数も他のプロセスによって CPU 利用が圧迫されている場合に減ってしまうと考えられるため、もっとうまいやり方でやるべきかも... と思っています。

さておき、ここまでの処理で `bits` ベクタには長さ 40 のビット列が格納されているはずです。後続の `for chunk in bits.chunks(8)` あたりの処理で、このビット列を 8bit ずつまとめ、`bytes` ベクタに 5 つの u8 (8bit 符号なし整数) として格納していきます。このとき、`bytes[0]` には湿度の整数部分、`bytes[1]` にはオールゼロ、`bytes[2]` には気温の整数部分、`bytes[3]` には気温の小数部分、`bytes[4]` にはパリティが格納されます。パリティと取得したデータを比較する際には、`let check = bytes[0] + bytes[1] + bytes[2] + bytes[3];` のようにすべてのデータを足し合わせ、パリティと等しいかを見ます。

もしパリティと違えばエラーを返しますし、合えば `dht11::Metric` 構造体に気温・湿度・パリティを含めて返します。気温の変換はかなり雑ですが、ちゃんとやるなら IEEE 754 形式で浮動小数点数を組み立てて `f64::from_bits()` を利用して f64 に変換すべきな気もします...。

### 実行結果

このコードをビルドして実機に送ってから実行すると、以下のような感じで結果が出てきます。

```
[root@selene-001 mozamimy]# ./raspi-dht11
Temp: 18.2C, Hum: 61%, Parity: 81
Temp: 20.5C, Hum: 60%, Parity: 85
Temp: 20.4C, Hum: 64%, Parity: 88
Temp: 20.4C, Hum: 64%, Parity: 88
Temp: 20.5C, Hum: 64%, Parity: 89
Temp: 20.5C, Hum: 64%, Parity: 89
Temp: 20.5C, Hum: 64%, Parity: 89
Temp: 20.5C, Hum: 64%, Parity: 89
Temp: 20.5C, Hum: 64%, Parity: 89
Temp: 20.5C, Hum: 64%, Parity: 89
Temp: 20.5C, Hum: 64%, Parity: 89
Temp: 20.5C, Hum: 64%, Parity: 89
The expected parity is 88, however it received 72
timeout
timeout
Temp: 20.5C, Hum: 63%, Parity: 88
Temp: 20.6C, Hum: 63%, Parity: 89
Temp: 20.5C, Hum: 63%, Parity: 88
Temp: 20.6C, Hum: 63%, Parity: 89
Temp: 20.6C, Hum: 63%, Parity: 89
Temp: 20.5C, Hum: 63%, Parity: 88
Temp: 20.6C, Hum: 63%, Parity: 89
Temp: 20.6C, Hum: 63%, Parity: 89
Temp: 20.6C, Hum: 63%, Parity: 89
Temp: 20.7C, Hum: 63%, Parity: 90
Temp: 20.6C, Hum: 63%, Parity: 89
Temp: 20.7C, Hum: 63%, Parity: 90
^C
```

ちゃんと (?) たまにパリティチェックに引っかかったり、タイムアウトしていたりしますね。

## まとめ

まだまだ実装が荒削りな部分もありますが、ひとまず Raspberry Pi 4 と DHT11 を利用して温湿度を取得することができました。

このように、Raspberry Pi 4 は「ふつうの Linux」として扱えつつも、電子工作を楽しめる「ちょうどいい」計算機だと思います。Rust や Ruby といった現代的で高級なプログラミング言語を使って、いつもどおりのやり方でプログラムを作れるのでとても楽です。

このコードを Prometheus 用に exporter 化し、Grafana で可視化し、AlertManager で異常を知らせるというのが最終的な目標なので、その作業が一区切りついたらまた記事にしようと思います。

それでは。

---
title: 懐かしの blink タグを復活させる Firefox アドオン
date: 2016-03-23
tags: web, tool
---

<img src='/2016/03/23/blink/blink.gif' style='width: 600px;'>

## Web 1.0

Web 2.0 もすっかりと錆びてしまったバズワードですが、Web 2.0 がさけばれる以前のインターネットは、今思えばたいへん情緒あふれる世界だったように思います。

原色バリバリのたいへん目にきびしいカラーリングに、marquee タグに囲まれた文字が画面をさっそうと駆け抜け、blink タグで装飾された画像がビカビカとその存在をアピールし、踏み逃げ禁止のウェブサイトで後ろめたい思いをしながら踏み逃げをしたあの頃。

なにもかもが、なつかしいです。

## blink タグ

Web 1.0 を彩ってきたウェブ技術の中でも、`<blink>` タグはきわめて印象的なもののひとつでしょう。

`<blink>` タグは、いつからか Firefox でも Chromium でもビカビカしなくなり、その生命はすっかり絶たれてしまいました。blink しない `<blink>` タグになんの価値があるというのでしょうか。

<marquee style='background-color: red; color: green; font-weight: bold;'>そしてなぜ、`<marquee>` タグはお目こぼしをもらっているのでしょうか。</marquee>

## remember-blink

`<blink>` がビカビカしていた頃はうっとうしてくてしょうがなかったのですが、いざ死んでいなくなってみると、心にぽっかりと穴が空いたようでした。

もう一度、`<blink>` が元気に光りまわるあの姿を見たい。

その思いが昂じて、[remember-blink](https://github.com/mozamimy/remember-blink) という Firefox アドオンを作ってしまいました。

[remember-blink](https://github.com/mozamimy/remember-blink) を導入すると、以下の文字が元気に光りまわるようになります。

<blink style='font-size: 300%;'>BLINK</blink>

i アプリで動く Twitter のクライアントを作っていたあの頃に戻りたい。

---
title: Ariete 1.0.3 をリリースしました
date: 2015-09-16
tags: ruby
---

Ariete 1.0.3 をリリースしました。このリリースは、minitest、test-unit など、RSpec 以外で利用できない問題を修正するものです。

RubyGems.org にもアップロードされているので、`bundle update` などでアップデートすることも可能です。

## アーカイブのダウンロード

[https://github.com/mozamimy/ariete/releases/tag/1.0.3](https://github.com/mozamimy/ariete/releases/tag/1.0.3)

## ソースコード

[https://github.com/mozamimy/ariete/tree/1.0.3](https://github.com/mozamimy/ariete/tree/1.0.3)

## 修正の内容

取り込んだ主な PR は以下になります。

- [Fix NameError in case of using test-unit by stk132 · Pull Request #3 · mozamimy/ariete](https://github.com/mozamimy/ariete/pull/3)
- [Update Gemfile.lock. by mozamimy · Pull Request #6 · mozamimy/ariete](https://github.com/mozamimy/ariete/pull/6)

現在、Ariete 内では RSpec のマッチャー🍵を拡張するコードをベタ書きしています。そのため、RSpec を使わない環境でも RSpec を入れないと動かないという大問題があります。#3 の PR は、この問題に対するホットフィックスになります。[@stk132](https://github.com/stk132)さんありがとう!🐰

この問題を避けるため、ariete gem には Ariete のコア部分だけを含め、RSpec を拡張するコードは ariete-rspec gem を新たに作って分離しようと考えています。余裕があれば、ariete-minitest や ariete-test-unit も作る予定です。

かしこ。

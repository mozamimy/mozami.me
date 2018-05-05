---
title: Slack の発言を他のチャンネルに転送するためのツール「telescreen」
date: 2017-05-07
tags: rust, tool
---

前々から作ろうと思いつつなかなか手が動かなかったのですが、ゴールデンウィークで暇を持て余してたこともあり、勢いで telescreen というツールを作りました。

<blockquote class="embedly-card"><h4><a href="https://github.com/mozamimy/telescreen">mozamimy/telescreen</a></h4><p>telescreen - A slack bot to forward messages by simple routing definition</p></blockquote>
<script async src="//cdn.embedly.com/widgets/platform.js" charset="UTF-8"></script>

telescreen は Slack の bot として常駐し、join しているチャンネルの発言を他のチャンネルに転送するためのツールです。人間の発言を集めたいというモチベーションで実装したため、bot による発言は転送しません。
利用には [Bot integration](https://slack.com/apps/A0F7YS25R-bots) で発行することのできる API トークンが必要になります。

## ふんいき

こんな感じの YAML による設定を書くと

```yaml
- match: 'personal-.+'
  destinations:
    - personal-timeline
- match: '.*'
  destinations:
    - public-timeline
```

こんな感じで発言を別のチャンネルに転送します。

<a href="/2017/05/07/telescreen_v0_1_0/telescreen.gif" target="_blank">
  <img src="/2017/05/07/telescreen_v0_1_0/telescreen.gif" style="width: 700px;">
</a>

personal- からはじまるチャンネルの発言は #personal-timeline チャンネルに転送しつつ、全てのチャンネルでの発言は #public-timeline に転送する、という感じです。

設定ファイルは YAML で書き、`{ match: 正規表現, destinations: [channel1, channel2, ... ] }` というようなハッシュの配列になっています。`match` で指定した正規表現にひっかかるチャンネルでの発言が、`destinations` に列挙されたチャンネルに転送されます。

telescreen を使うことで、たとえば全チャンネルでの発言を #public-timeline に転送し、いわゆる分報チャンネルでの発言は #funho-timeline に集める、というようなことが可能です。

## インストール・使い方

[リリースページ](https://github.com/mozamimy/telescreen/releases) にあるビルド済みのバイナリを使うか、Rust および cargo がインストールされているなら、`$ cargo install telescreen` してください。

起動は以下のような感じ。API key と設定ファイルの場所を引数で指定します。

```
$ telescreen --api-key=foobar --config=config.yml
```

もともと [Amazon EC2 Container Service](https://aws.amazon.com/jp/ecs/) で動かすつもりだったので、[Docker イメージも用意してあります](https://hub.docker.com/r/mozamimy/telescreen/)。

[Entrykit](https://github.com/progrium/entrykit) を使って以下のように設定ファイルをテンプレート化しているので、環境変数 `DEST_CHANNEL` に転送先のチャンネルを設定すればすぐに使い始められます。
込み入った設定をしたい場合は、適宜 mozamimy/telescreen イメージをベースにしたイメージを作るなり、いい感じにしてください。

```yaml
- match: '.*'
  destinations:
    - {{ var "DEST_CHANNEL" | default "general" }}
```

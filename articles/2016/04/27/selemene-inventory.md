---
title: LGTM 用 gif アニメをシュッと探せる Selemene 0.2.0 をリリースしました
date: 2016-04-27
tags: programming
---

[LGTM 用の gif 画像をパッと探してポッと貼れるアプリを Electron で作ってみました](/2016/03/27/selemene-release.html) で紹介した Selemene をアップデートしました。

`Your inventory of animated gifs for LGTM.` を実現すべく、いちばん欲しかった倉庫機能を実装しました。以下の GitHub ページからダウンロードできます。

[Release v0.2.0](https://github.com/mozamimy/selemene/releases/tag/v0.2.0)

## 倉庫機能

![](/images/2016/04/27/selemene-inventory/selemene.gif)

検索画面で適当にポチポチ `F` キーを押すと、gif アニメをお気に入りして倉庫にしまうことができます。また、`L` キーで倉庫画面に遷移して、検索画面と同じように、倉庫にしまった gif アニメの選択とクリップボードへのコピーができます。倉庫画面で倉庫に入れた画像を削除するときは、`D` キーで倉庫から削除できます。検索画面に戻るときは `H` キーで戻れます。

## 次にやること

- そろそろつらいのでユニットテストを導入する
- クリップボードにコピーした gif アニメの履歴機能をつける
- 倉庫にしまうときに tag をつけて検索できるようにする
- 検索結果で 10 個ごとにロードしてどんどん深掘りできるようにする
- 直接 DOM を操作するのをやめたい
- .selemene ファイルを書いて設定できるようにする
- 検索ソースを Tumblr API に変えることを検討する

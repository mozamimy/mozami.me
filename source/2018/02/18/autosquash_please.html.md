---
title: fixup! なコミットを含む pull request で merge ボタンを押せなくするブラウザ拡張を作った
date: 2018-02-18
tags: web, tool
---

GitHub および GitHub Enterprise (以下 GHE と表記) で `fixup!` なコミットを含む pull request で merge ボタンを押せなくするブラウザ拡張 **autosquash-please** を作りました。Firefox と Chrome で動きます。具体的な動作イメージは以下のスクリーンショットを見てください。

<img alt='autosquash-please' src='/2018/02/18/autosquash_please/autosquash-please.png' style="width: 700px;">

このように、コミットの一覧に `!fixup foobar` のようなコミットが含まれていると、マージボタンがかくれるだけの拡張です。

## どのような場合に役に立つの?

1 pull request に対して 1 commit にまとめたいとき、わたしは Git のコミット時に `--fixup` オプションを利用してレビューコメントに対する修正を入れ、merge 前に `git rebase -i --autosquash=HEAD^3` のようにしてコミットをまとめてから merge ボタンを押す、ということをしばしば行います。

このとき、rebase を忘れて `fixup! nanika` のようなコミットが master に merge されてしまうと、末代まで残る恥をかくことになります (実際何回かやらかしてます..)。

autosquash-please は `fixup!` を含むコミットが存在するときに merge ボタンを隠すので、このような事故が起こらなくなります。

## インストール

ソースコードは以下のリポジトリから入手できます。アドオンストアにアップロードしていないので、git clone するなりしてダウンロードする必要があります。

[mozamimy/autosquash-please: An WebExtension to prevent merging of a pull request that contains `fixup!` commits on GitHub (also Enterprise).](https://github.com/mozamimy/autosquash-please)

Firefox なら `about:debugging` を開き、**Load Temporary Add-on** ボタンを押し、ダウンロードしたディレクトリ中の manifest.json ファイルを選択してください。

Chrome なら `chrome://extensions/` を開き、**Load unpacked extension** ボタンを押し、ダウンロードしたディレクトリを選択してください。

アドオンを追加したあとに、 オプションを開いて GitHub の設定画面で生成できる personal access token を追加してください。許可するアクションは `repo` だけで十分です。

## 実装について

github.com や設定した GHE の pull request のページを開いたときに、対応する pull request に紐づくコミットを GitHub API から引っ張ってきて、`fixup!` から始まるコミットを含んでいたら、筋肉で DOM ツリーを操作してボタンを見えなくしています。

せっかくなので Chrome にも対応したいと思い、いくつかの非互換を埋めるために以下の webextension-polyfill を利用しました。

[mozilla/webextension-polyfill: A lightweight polyfill library for Promise-based WebExtension APIs in Chrome](https://github.com/mozilla/webextension-polyfill)

標準化の進む WebExtension を利用すれば、ドキュメントも豊富ですし、ちょっとした拡張なら Firefox と Chrome で動くものがシュッと作れるので、小さなアドオンをどんどん作って作業の効率化を進めていきたいなーと思う今日このごろです。

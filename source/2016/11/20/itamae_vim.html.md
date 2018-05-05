---
title: Itamae 用の Vim syntax プラグイン Itamae.vim の紹介
date: 2016-11-20
tags: ruby, vim, infra, tool
---

<img alt='itamae.vim 'src='/2016/11/20/itamae_vim/itamae.vim.png' style='width: 600px;'>

インフラの構成管理が Ruby の DSL でできて便利な [Itamae](https://github.com/itamae-kitchen/itamae) ですが、Vim で書いてるときに、キーワードっぽいメソッドに色がつかないのが地味に不便でした。

Itamae 向けの Vim の syntax が、ちょっと探してもなさそうだったのでサクッと作りました。以下の GitHub リポジトリからダウンロードできます。

[https://github.com/mozamimy/itamae.vim](https://github.com/mozamimy/itamae.vim)

これを作るにあたっては、[Nymphia.vim](https://github.com/mozamimy/nymphia.vim) で得た知見が生きました。Ruby をベースとしてキーワードをハイライトする、という点では同様なので。

楽しい Itamae & Vim ライフの手助けになれば幸いです 🐰

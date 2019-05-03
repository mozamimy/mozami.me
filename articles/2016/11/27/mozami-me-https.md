---
title: mozami.me を HTTPS 化して CI でデプロイできるようにした
date: 2016-11-27
tags: infra
---

ずっとやろうと思いつつ、なんとなくだるくてやってなかった mozami.me の HTTPS 化をしました。

構成は、S3 バケットをオリジンにした CloudFront の distribute を作って、証明書は ACM で発行したものを使ってます。静的なサイトなら定番の構成ですね。さようなら Github Pages..

ついでに、これまたやろうと思いつつだるくてやってなかったブログの自動デプロイを仕込みました。以下のような感じで Travis CI の設定を書くと、master ブランチに merge した瞬間に Middleman のビルドが走ってデプロイされます。

[https://github.com/mozamimy/source.mozamimy.github.io/blob/master/.travis.yml](https://github.com/mozamimy/source.mozamimy.github.io/blob/master/.travis.yml)

<p>
{{ embed_code "/2016/11/27/travis.yml" }}
</p>

Travis CI の deploy の provider として s3 があるのですが、削除されたファイルはそのまま、つまり `aws s3 sync build s3://mozami.me/ --delete` の `--delete` なし相当の挙動をするということだったので、複雑になるなと思いつつ、pip で awscli をインストールして、それを使うようにしてます。

また、デプロイ用の IAM ユーザを作り、`env` に その IAM ユーザのクレデンシャルを travis コマンドで暗号化したものをつっこんでいます。

ハンズフリーでシュッとデプロイされてべんり🐰

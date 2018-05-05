---
title: mozami.me を HTTPS 化して CI でデプロイできるようにした
date: 2016-11-27
tagls: note, infra, web
---

ずっとやろうと思いつつ、なんとなくだるくてやってなかった mozami.me の HTTPS 化をしました。

構成は、S3 バケットをオリジンにした CloudFront の distribute を作って、証明書は ACM で発行したものを使ってます。静的なサイトなら定番の構成ですね。さようなら Github Pages..

ついでに、これまたやろうと思いつつだるくてやってなかったブログの自動デプロイを仕込みました。以下のような感じで Travis CI の設定を書くと、master ブランチに merge した瞬間に Middleman のビルドが走ってデプロイされます。

[https://github.com/mozamimy/source.mozamimy.github.io/blob/master/.travis.yml](https://github.com/mozamimy/source.mozamimy.github.io/blob/master/.travis.yml)

```yaml

language: ruby
sudo: false
rvm:
  - 2.3.3
script:
  - bundle exec middleman build
env:
  global:
    - PATH=$PATH:$HOME/.local/bin
    - AWS_REGION=ap-northeast-1
    - AWS_DEFAULT_REGION=ap-northeast-1
    - secure: "XGQ0s6x3qNEVKCW5IiLdmC6JWBydFepT75ejFJCfmarCQwgKamyeeII+ZBx5TtJ5QByeQGemy7SXygVSTpaksRgBXkiEhxpP106nrlcxcPH6VldXN+Jt0MhaAO43Jf7a329/rq9LQt7juOAUBLTpVXXqyI2kZGWD638S9yL+NdNtNCB4BofREZcYlTbXK7bFVpC803his5BWXNCEGrnEW4OLxWzMRpYkO7FASQwwbwYcBY3yvimhYCK42rGN3sbeS1QG9HFxCzT2lmbegA0O7WnU7BOa3gDaNeRM1sQsfBUcREf+rCvySXsZvVzF/GN9e3WycDoKtLVACQk6FGOIepHZDvxcKM75iG8G7sJMQlHs0uVNOSmQvoEhVQWHL9nL9EGeTvVqsyod1X1eMCSFcd6iW2Zo2cd/Y31EvcvR/yLmJiveqHHMs09kCjLCjnQcGef52CjJW8jVYgIF05Wm2NqgPobM1ammP8gImLKdHNNV/Lq4zxch5VeJxn5A9xlEYw4ShBJJX+7OdLqLZ3fCIkOXr6uLxL/nQIm2bzNXG+u/lztJRUF7vBaLk9bq20q66F2/9HQcDeznsGlSRuQxqR8foAp9w369xcudw2jiw42xVrWiAvMPZuTFhfMRoedXFKkKSQOMHTT7Tg4ncpxcm7yRhQgCSW8InPB/cM9fh/0="
    - secure: "dbNq94Bd6Wv03EDlY5nVmQTE5MtYF8aO+b78VXnvRxEFhzRIDZtxqJidP7dYUTnc1ZzQFdsOC3E1O5kN3h1TcP7VgsRrcRbkf0SIhP350GBGdpqxLHOUohdvyIO7QPo0wynvHCBZnZkYGjA7Nrs7l5kWtkGA4cXXK+wwusKGGsrPXth5/YhRVjrFaYCFSTCNP1/hDmg8ORuF5yecMLMuqb66QuTW5k9QJUpdeGgbZiMWQvyIgw3oUB/LtOyb2Yjzw54BK89ZWASuGyDDkbrf51uPE+4MyxMncZ9yXCE7imkJ0wTyE5IlMwEU5Jj9IAmCDpGKcDT4+Qh3yfOzpe5FzjI/b9Mm0pjKp4UOkaidaZ39a8rW9pOZP4kM9hN/zHh8w5A4kYzkGw4UZNNxQCW3FWV1YeZzrwMa8pBx/cU75DaiIoFrJwRUMNbdU5QxwFA6EIDHSMm9ZiyUJWBkginufd+G40mlpIKM4nvYQx3Be59aY1yU4SAf9QXBBa1hS7JtRtP8iLoa3M0zowZORT70tIkYpSSttq8uXn6XAMTGaLwfouL7YSkoimE99PuQpXoqSBCfP9XBYaer06X1Ca37pUiThio3JzFR3h0N6pNFIzAQUm98nKrIw1VMSZMPwMZi7J97jCs8u4Pah7IDuz/3mot++ts7hQMvTFW8TnufFAQ="
before_install:
  - pip install --user awscli
deploy:
  provider: script
  skip_cleanup: true
  script:
    - "aws s3 sync build s3://mozami.me/ --delete"
  on:
    branch: master
notifications:
  on_success: always
  on_failure: always
  on_start: false
```

Travis CI の deploy の provider として s3 があるのですが、削除されたファイルはそのまま、つまり `aws s3 sync build s3://mozami.me/ --delete` の `--delete` なし相当の挙動をするということだったので、複雑になるなと思いつつ、pip で awscli をインストールして、それを使うようにしてます。

また、デプロイ用の IAM ユーザを作り、`env` に その IAM ユーザのクレデンシャルを travis コマンドで暗号化したものをつっこんでいます。

ハンズフリーでシュッとデプロイされてべんり🐰

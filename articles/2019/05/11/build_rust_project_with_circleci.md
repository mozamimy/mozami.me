---
title: Rust のプロジェクトを CircleCI でテストしてリリースまで自動化するための設定例
date: 2019-05-11
tags: programming
---

[先日このブログを自作の Salmon という静的サイトジェネレータに移行した](/2019/05/03/salmon.html) というエントリを書きましたが、快適に開発を進めていくために CI 環境を整えようと思いたち、ちまちまと CircleCI を設定していました。

以前から Travis CI を個人プロジェクトで利用してきましたが、少し前から本格的に CircleCI を利用しはじめてみたところ、非常に手に馴染む感じがして気に入りました。じつは CircleCI 2.0 になる前にも少し使ったことがあったのですが、2.0 になって Docker ベースになったため、もろもろの概念や裏側で何が起こっているのかも理解・推測しやすくて扱いやすいです。

不慣れなのではじめは上手に設定が書けませんでしたが、ドキュメントとにらめっこしながらパターンを学んでいき、ようやく Rust プロジェクトでコミットをプッシュするたびにテストを走らせ、リリース (`docker push` および `cargo publish`) するところまで自動化できたので、メモとしてこのエントリを書くことにしました。

設定を書く際には [https://www.ncaq.net/2019/03/08/21/12/35/](https://www.ncaq.net/2019/03/08/21/12/35/) のエントリも参考にしました。

## Salmon で実際に利用している .circleci/config.yml

[https://github.com/mozamimy/salmon/blob/b8bfa448e5255ed89ee1b7a27750a7028baabe17/.circleci/config.yml](https://github.com/mozamimy/salmon/blob/b8bfa448e5255ed89ee1b7a27750a7028baabe17/.circleci/config.yml) に設定の YAML ファイルがあります。このエントリを書いてからも変更を加えている可能性があるため、master ブランチの設定は変わっているかもしれません。

<p>
{{ embed_code "/2019/05/11/config.yml" }}
</p>

### 2 つの executor を定義する

`executors` に `default` と `docker` の 2 つの executor を定義し、それぞれバイナリをビルドする用と Docker イメージをビルドする用としました。[CircleCI の Pre-Built CircleCI Docker Images](https://circleci.com/docs/2.0/circleci-images/#rust) を見たところ、Rust 用のイメージが用意されているようでしたが、[当該の Dockerfile](https://github.com/CircleCI-Public/circleci-dockerfiles/blob/master/rust/images/1.34.1-stretch/Dockerfile) をざっと見たところ、特にこのイメージに含まれているツール類は必要なさそうだったので、`rust:1.34.1-stretch` イメージを利用することにしました。

### workflow は普段のテスト用とリリース用に分ける

workflow では `run_test` と `release` という 2 種類の workflow を定義し、それぞれ master ブランチや pull request のビルド用、リリース作業の自動化用としました。`release` workflow は、タグが `vx.y.z` であるようなタグが push されたときのみ発火するようになっています。GitHub のリリース機能を使うと Git のタグが打たれるため、その場合に `release` workflow が実行されて `docker push` や `cargo publish` が行われます。

`run_test` は以下のような感じ。

<img src="/images/2019/05/11/workflow_run_test.png" style="width: 700px;">

`release` は以下のような感じ。

<img src="/images/2019/05/11/workflow_release.png" style="width: 700px;">

`cargo fmt` による lint と `cargo build` による build は並列に実行し、それぞれが正常に終了したら `cargo test` でテストケースを流したあと、`release` の場合はさらに `docker build` と `cargo package/publish` を並列に実行します。このようなパイプラインを簡単にガチャガチャ組めるのは楽しいですね。

本当は `docker build` と `docker push` は job を分割して `cargo build` などを流している間にも投機的に `docker build` を実行したかったのですが、Docker layer caching を使うためにはプランを変更する必要があり、さもなくば自前でキャッシュをがんばる必要があったので今回は見送りました。そういうわけで、`docker_layer_caching: true` となっていますが、実はこれは効いていません。

### キャッシュを利用して少しでも高速にコンパイルする

Rust はお世辞にもビルドが速いとはいえないため、毎回依存ライブラリをビルドしていると悲しいことになります。幸い CircleCI には組み込みのキャッシュ機能があるため、ビルド済みの依存ライブラリをキャッシュして再利用することができます。

キャッシュキーは、ちょっと苦しい感じなのですが `v1-cargo-lock-\{{ checksum "Cargo.lock"}}<<# parameters.release >>-release<</ parameters.release>>` としました。`build` job ではパラメータを使ってデバッグビルドとリリースビルドを切り替えられるようにしているため、キャッシュキーの中でパラメータを見て `-release` という文字を入れるか入れないかを切り替えています。

### ${CIRCLE_TAG} 環境変数から Git タグを取得して Docker イメージを焼いてアップロードする

[CircleCI では組み込みの環境変数がいろいろ用意されており](https://circleci.com/docs/2.0/env-vars/#built-in-environment-variables)、たとえば Git タグは `CIRCLE_TAG` 環境変数を通じて知ることができます。

`build_and_push_docker_image` job では、`CIRCLE_TAG` 環境変数の中身の `v0.1.0` のような文字列を `0.1.0` のような形に整形し、その値を使って `docker build` や `docker push` をして Docker Hub にイメージをアップロードしています。

## メモリ不足でときどきビルドがコケる問題

たとえば、[https://circleci.com/gh/mozamimy/salmon/93](https://circleci.com/gh/mozamimy/salmon/93) の実行のように、ときどき (いつもではない) ビルドがコケる現象に悩まされ、やや難儀しました。CircleCI では `resource_class` を使えるプランに移行しない限り、ビルド環境として与えられるのは 2 CPU と 4096 MB のメモリになるため、その制限内でビルドできるようにしないといけません。

いろいろ調べて、結局 Salmon が利用している libsass のラッパーである [sass-rs](https://github.com/compass-rs/sass-rs) の、libsass をビルドする [sass-sys](https://github.com/compass-rs/sass-rs/tree/master/sass-sys) でコケていることがわかりました。

sass-sys の build.rs にある実装を見てみると、[どうやら libsass を make するときに CPU のコア数をもとに並列数を決めている](https://github.com/compass-rs/sass-rs/blob/ab12782bdeeb862ca4f68656f76266a432ce6bdd/sass-sys/build.rs#L74)ということがわかりました。

世の中にはいろいろなコンテナランタイムがありますが、Docker ではナイーブに CPU の数を取得して並列数を決めた場合、意図しない値になることがあります。CircleCI 環境では、どうやらホストマシンは 36 個の CPU コアが載っているようで、libsass のビルドも 36 並列で行われた結果、メモリ不足に陥っているようでした。

そこで、`MAKE_LIBSASS_JOBS` 環境変数から並列数を差し込めるようにする [Override --jobs option value with an env var in build.rs by mozamimy · Pull Request #43 · compass-rs/sass-rs](https://github.com/compass-rs/sass-rs/pull/43) のような pull request を投げました。まだ本体には入っていないため、Salmon ではわたしの fork 版を利用するように Cargo.toml に設定しています。

ただ、悲しいことに Cargo.toml 中で `sass-rs = { git = "https://github.com/mozamimy/sass-rs.git", branch = "make-libsass-env" }` のように Git リポジトリをソースとして設定すると、`cargo publish` できないため、今は `publish_crate` ジョブの一部をコメントアウトした状態にし、Docker イメージだけリリースするような状態になっています..。

## まとめ

Rust プロジェクトを CircleCI でテストしてリリースまで自動化するための設定の一例を紹介しました。テストの実行やリリースを自動化できると、開発に集中できてよいですね。

改善点やご意見、ご感想があれば [@mozamimy](https://twitter.com/mozamimy) までおしらせていただけるとよろこびます。

---
title: Travis CI + Ruby 2.1.10 環境下で curses gem のビルドが落ちる問題のワークアラウンド
date: 2016-04-10
tags: infra, ruby
---

## TL; DR

.travis.yml に以下のセクションを追加するとビルドが通ります。docker container を使っていない場合は、`before_install` セクションで `sudo apt-get install -y libgmp-dev` などとするとよいでしょう。

```yaml
addons:
  apt:
    packages:
      - libgmp-dev
```

## ワークアラウンドを見つけるまでの道のり

### ことの発端

先日、Ruby 2.1.9 および 2.1.10 がリリースされたので、拙作のアプリ、[rbtclk](https://github.com/mozamimy/rbtclk) の .travis.yml ファイルに 2.1.10 を追加したらビルドが落ちました..

[落ちたビルド](https://travis-ci.org/mozamimy/rbtclk/jobs/122003748) (以下はログを一部抜粋)

```
Installing curses 1.0.2 with native extensions
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.
    /home/travis/.rvm/rubies/ruby-2.1.10/bin/ruby -r
    ./siteconf20160410-4346-18ebz4v.rb extconf.rb
    checking for tgetent() in -ltinfo... *** extconf.rb failed ***
    Could not create Makefile due to some reason, probably lack of necessary
    libraries and/or headers.  Check the mkmf.log file for more details.  You may
    need configuration options.
```

### Docker image を使って落ちる原因をさぐる

ビルドがエラーで落ちたとき、Travis CI のビルドログに出てくる情報だけでは原因をさぐることが難しいです。そこで、[Travis CI の docker image をローカルでビョーンとしてみました](/2016/03/21/travis-runner.html) で紹介したように、[Travis CI の Docker image](https://quay.io/organization/travisci) を使うと超べんりです。

Docker image の中で Ruby 2.1.10 をインストールして、`gem install curses -v '1.0.2'` してみたところ、もくろみ通り同じところで落ちて、mkmf.log に以下のようなログが残りました。

```
"gcc -o conftest -I/home/travis/.rvm/rubies/ruby-2.1.10/include/ruby-2.1.0/x86_64-linux -I/home/travis/.rvm/rubies/ruby-2.1.10/include/ruby-2.1.0/ruby/backward -I/home/travis/.rvm/rubies/ruby-2.1.10/include/ruby-2.1.0 -I.     -O3 -fno-fast-math -ggdb3 -Wall -Wextra -Wno-unused-parameter -Wno-parentheses -Wno-long-long -Wno-missing-field-initializers -Wunused-variable -Wpointer-arith -Wwrite-strings -Wdeclaration-after-statement -Wimplicit-function-declaration  -fPIC conftest.c  -L. -L/home/travis/.rvm/rubies/ruby-2.1.10/lib -Wl,-R/home/travis/.rvm/rubies/ruby-2.1.10/lib -L. -fstack-protector -rdynamic -Wl,-export-dynamic     -Wl,-rpath,'/../lib' -Wl,-R -Wl,'/../lib' -L'/../lib' -lruby  -lpthread -lrt -lgmp -ldl -lcrypt -lm   -lc"
/usr/bin/ld: cannot find -lgmp
collect2: ld returned 1 exit status
checked program was:
/* begin */
1: #include "ruby.h"
2:
3: int main(int argc, char **argv)
4: {
5:   return 0;
6: }
/* end */
```

「lgmp がないぞ💢」と怒られているので、libgmp-dev をインストールすると curses gem がビルドできるようになりました🍭

根本的な原因は謎ですが、ワークアラウンドを発見できたのでめでたしめでたし。

Travis CI でトラブルが起きたときは Docker image が超べんりなのでガンガン活用していきましょう💪

---
title: mitamae でレシピの中で使える独自のヘルパメソッドを定義する方法
date: 2018-09-04
tags: infra
---

以前の記事で、カジュアルに Itamae を拡張するためのヘルパメソッドを定義する方法を紹介しました。

[Itamae でレシピとリソースに共通のヘルパメソッドを定義するテクニック | Cry for the Moon](https://mozami.me/2016/07/17/itamae_hack.html)

ここのところ、開発環境を含めて雑草にあふれたおうちインフラを刷新する活動をしていて、その一環で [Itamae](https://github.com/itamae-kitchen/itamae) + SSH から [mitamae](https://github.com/itamae-kitchen/mitamae) + [hocho](https://github.com/sorah/hocho) に切り替えていく中で、上述の記事に書いたようなことを mitamae でもやりたくなったので、その方法をメモしておきます。

## 例: role や cookbook を探索して include するようなメソッドを生やす

たとえば、base および bastion という名前の 2 つの role があり、aws-cli という名前の cookbook があるとしましょう。mitamae (正確には Itamae 由来) のベストプラクティスにしたがうと、以下のようなディレクトリツリーになります。

```
.
├── cookbooks
│   └── aws-cli
│       └── default.rb
└── roles
    ├── base
    │   └── default.rb
    └── bastion
        └── default.rb
```

ここで、bastion role は base role に対する変更をすべて含めたいものとし、base role には aws-cli cookbook を含めたいものとします。

このような場合に、他のファイルを読み込むための `include_recpie` メソッドを素朴に使うと、それぞれの default.rb は以下のようになります。

```ruby
# cookbooks/aws-cli/default.rb
package 'aws-cli' do
  action :install
end
```

```ruby
# roles/base/default.rb
include_recipe '../../../cookbooks/aws-cli/default.rb'
```

```ruby
# roles/bastion/default.rb
include_recipe '../../base/default.rb'
```

もちろんこれで動きますし十分です。しかし、さらに見栄え良く書きたいと思うと、以下のような `include_cookbook` および `include_role` というメソッドがあると便利そうです。

```ruby
# roles/base/default.rb
include_cookbook 'aws-cli'
```

```ruby
# roles/bastion/default.rb
include_role 'base'
```

これは、cookbooks および roles ディレクトリを探索し、合致する cookbook や role が見つかれば、それを `include_recipe` するようなメソッドです。

## ヘルパメソッドをまとめたモジュールを作って include する

発想としては [Itamae でレシピとリソースに共通のヘルパメソッドを定義するテクニック | Cry for the Moon](https://mozami.me/2016/07/17/itamae_hack.html) とほぼ同じです。

helpers/recipe_helper.rb に、ヘルパメソッドをまとめた `RecipeHelper` のような module を定義し、`MItamae::RecipeContext` に `include` してあげます。

```ruby
# helpers/recipe_helper.rb

module RecipeHelper
  def include_role(name)
    include_role_or_cookbook(name, 'role')
  end

  def include_cookbook(name)
    include_role_or_cookbook(name, 'cookbook')
  end

  def include_role_or_cookbook(name, type)
    tmp = ''
    File.dirname(@recipe.path).split('/').reject {|d| d == '' }.map {|d| tmp = "#{tmp}/#{d}"; tmp }.reverse.each do |dir|
      names = name.split('::')
      names << 'default' if names.length == 1
      names[-1] += '.rb'
      if type == 'cookbook'
        recipe_file = "#{dir}/" + ['cookbooks'].concat(names).flatten.join('/')
      else
        recipe_file = "#{dir}/" + names.join('/')
      end
      if File.exist?(recipe_file)
        include_recipe(recipe_file)
        return
      end
    end

    raise "#{type.capitalize} #{name} is not found."
  end
end

MItamae::RecipeContext.include(RecipeHelper)
```

もともとこれは Itamae で利用していた秘伝のタレともいえるコードが元になっており、pathname ライブラリを用いてもう少し簡潔に書かれていたものでした。

pathname ライブラリを使うことができれば 12 行目や 17 行目、19 行目はもう少し簡潔になりますが、mruby を使っている以上は別の方法でやるしかありませんし、mitamae そのものを拡張してビルドし直すのもちょっと違うなあという気持ちがあって、ゴリゴリッと愚直に書きました。ファイルパスが / 区切りではないシステムで動かすことは諦めています。

また、`include_cookbook 'foo::bar'` のように書くことで、cookbooks/foo/bar.rb が読み込まれるような仕掛けも入っています。

## recipe_helper.rb を mitamae に読み込ませる

[サーバーのプロビジョニングをmitamae + hochoでやる方法 - Qiita](https://qiita.com/k0kubun/items/f6a5ccc649a25fc61351#4-hochoyml-%E3%82%92%E7%94%A8%E6%84%8F%E3%81%99%E3%82%8B) に裏技として書かれているように、hocho の `mitamae_options` の先頭に helpers/recipe\_helper.rb を書くことで、mitamae を走らせる前に recipe\_helper.rb を読み込ませることができます。

```yaml
# hocho.yml
property_providers:
  - add_default:
      properties:
        preferred_driver: 'mitamae'

driver_options:
  mitamae:
    mitamae_path: '/usr/local/bin/mitamae'
    mitamae_options: ['helpers/recipe_helper.rb', '--log-level', 'info']
    mitamae_prepare_script: |
      curl -L https://github.com/itamae-kitchen/mitamae/releases/download/v1.6.2/mitamae-x86_64-linux > /usr/local/bin/mitamae &&
      echo "c3e0a1d3e7dfaac5057cf63c94a0cb34ec5570edbcc164d1a0573130315d3076  /usr/local/bin/mitamae" | /usr/bin/core_perl/shasum -a 256 -c &&
      chmod +x /usr/local/bin/mitamae
```

これで、無事 mitamae を拡張して、レシピ中で使える独自メソッドを定義することができるようになりました :rabbit: :bulb:
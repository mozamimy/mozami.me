---
title: Itamae でレシピとリソースに共通のヘルパメソッドを定義するテクニック
date: 2016-07-17
tags: infra, ruby
---

[Itamae](https://github.com/itamae-kitchen/itamae) 使ってますか？

Chef のような Ruby の DSL による気持ちのいい書き心地と、Ansible のようなシンプルさを兼ね備えており、わたしのお気に入りの構成管理ツールです。

## レシピとリソースにヘルパメソッドを追加したい

ある程度 Itamae のレシピが増えてくると、コードを DRY にするために、特定の処理やデータをメソッドとしてくくりだしておいて、各所で使いたくなることがあります。

Itamae は結局 Ruby なので、この目的を達成する方法はいろいろあると思います。この記事では、それなりにキレイと思われる、レシピとリソースに共通のヘルパメソッドを定義する方法を紹介します。

## ソースコードツリー

ファイル構成はこんな感じになります。Itamae スクリプトとして `recipe.rb` を実行したときに、`itamae_helper.rb` を読み込み、`itamae_helper.rb` が `helpers` ディレクトリ以下の .rb ファイルを読みにいきます。

```
・root_dir
┣・helpers
┃┣・common_helper.rb
┃┣・recipe_helper.rb
┃┗・resource_helper.rb
┣・itamae_helper.rb
┗・recipe.rb
```

## itamae_helper.rb

```ruby
require_relative './helpers/common_helper'
require_relative './helpers/recipe_helper'
require_relative './helpers/resource_helper'
```

## helpers

### common_helper.rb

```ruby
module CommonHelper
  def pyonpyon
    'pyonpyon'
  end
end


Itamae::Recipe::EvalContext.send(:include, CommonHelper)
Itamae::Resource::Base::EvalContext.send(:include, CommonHelper)
```

### recipe_helper.rb

```ruby
module RecipeHelper
  def mofmof
    'mofmof'
  end
end

Itamae::Recipe::EvalContext.send(:include, RecipeHelper)
```

### resource_helper.rb

```ruby
module ResourceHelper
  def fuwafuwa
    'fuwafuwa'
  end
end

Itamae::Resource::Base::EvalContext.send(:include, ResourceHelper)
```

## recipe.rb

```ruby
require_relative './itamae_helper'

pyonpyon # => 'pyonpyon'
mofmof # => 'mofmof'
fuwafuwa # recipe のコンテキストで定義されていないので、例外 NoMethodError が出る。

user 'usagi' do
  pyonpyon # => 'pyonpyon'
  fuwafuwa # => 'fuwafuwa'
  mofmof # resourece のコンテキストで定義されていないので、例外 NoMethodError が出る。
end
```

## 解説

ポイントは、

```ruby
Itamae::Recipe::EvalContext.send(:include, CommonHelper)
Itamae::Resource::Base::EvalContext.send(:include, CommonHelper)
```

の 2 行です。

このように書くことで、コードが recipe として評価されるコンテキストで、`include` を実行し、任意のモジュールをインクルードすることができます。

レシピとリソースで使うようなメソッドは `CommonHelper` に、レシピのみで使うなら `RecipeHelper` に、リソースのみで使うなら `ResourceHelper` に定義すると、メソッドの見える範囲が絞れてベターです。

このテクニック、地味に [usamimi-devenv](https://github.com/mozamimy/usamimi-devenv) (わたしの開発環境の itamae ファイルの置き場所)で利用しているのですが、便利です。

DRY な Itamae でスマートに構成管理をしましょう💓

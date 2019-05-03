require_relative './itamae_helper'

pyonpyon # => 'pyonpyon'
mofmof # => 'mofmof'
fuwafuwa # recipe のコンテキストで定義されていないので、例外 NoMethodError が出る。

user 'usagi' do
  pyonpyon # => 'pyonpyon'
  fuwafuwa # => 'fuwafuwa'
  mofmof # resourece のコンテキストで定義されていないので、例外 NoMethodError が出る。
end

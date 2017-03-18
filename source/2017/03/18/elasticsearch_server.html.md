---
title: 書籍 ElasticSearch Server と Elasticsearch 5.2
date: 2017-03-18
tags: infra
---

業務で Elasticsearch をやっていくことになったので、一通りわかっておきたいと思って、いわゆる「緑の本」を買って読みました。

<div class="amazlet-box"><div class="amazlet-image" style="float:left;margin:0px 12px -5px 0px;"><a href="http://www.amazon.co.jp/exec/obidos/ASIN/B00J4KDYZU" name="amazletlink" target="_blank"><img src="https://images-fe.ssl-images-amazon.com/images/I/510nupY-9zL._SL160_.jpg" alt="高速スケーラブル検索エンジン　ElasticSearch Server (アスキー書籍)" style="border: none;" /></a></div><div class="amazlet-info" style="line-height:120%; margin-bottom: 10px"><div class="amazlet-name" style="margin-bottom:10px;line-height:120%"><a href="http://www.amazon.co.jp/exec/obidos/ASIN/B00J4KDYZU" name="amazletlink" target="_blank">高速スケーラブル検索エンジン　ElasticSearch Server (アスキー書籍)</a><div class="amazlet-powered-date" style="font-size:80%;margin-top:5px;line-height:120%">posted with <a href="http://www.amazlet.com/" title="amazlet" target="_blank">amazlet</a> at 17.02.26</div></div><div class="amazlet-detail">KADOKAWA / アスキー・メディアワークス (2014-03-25)<br />売り上げランキング: 42,891<br /></div><div class="amazlet-sub-info" style="float: left;"><div class="amazlet-link" style="margin-top: 5px"><a href="http://www.amazon.co.jp/exec/obidos/ASIN/B00J4KDYZU" name="amazletlink" target="_blank">Amazon.co.jpで詳細を見る</a></div></div></div><div class="amazlet-footer" style="clear: left"></div></div>

Elasticsearch の利用と運用において知っておいたほうがよいことをまんべんなく知れる良書なのですが、書籍の対象とする Elasticsearch のバージョンが古いため、公式ドキュメントと突き合わせながら読んでいます。
Elasticsearch も公式ドキュメントが充実しているので良いですね。
本をインデックスとして、公式ドキュメントを読んで理解してくのがよいと思います。

いくつかサンプルがそのまま動かないパターンがあったりしたので、メモを書き残しておきます。この本を読む方の参考になれば幸いです。

## ローカルで Elasticsearch を動かす

まじめに Java からインストールするのはだるいので、Docker を使えばらくちん。7 章あたりでは適当に docker-compose.yml を書いてクラスタを組んで実験するのもよいでしょう。

```
# docker run -d -p 9200:9200 elasticsearch
```

## 検索 API の差異

- 2.3.5 で紹介されている `fields` フィルタは使えない。`stored_fields` もしくは `_source` フィルタを用いる
  - https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-stored-fields.html 
  - https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-source-filtering.html
- 2.3.5 で紹介されている `partial_fields` も廃止されている
  - https://github.com/elastic/elasticsearch/issues/4118 

## スクリプトの差異

2.3.6 で紹介されている検索時の script は、5.2 のデフォルトの Painless でそのまま動かない。Painless での `_source` に対するアクセスに関する議論は [GitHub の issue](https://github.com/elastic/elasticsearch/issues/20068) でされている。

ワークアラウンドとして `params._source` で `_source` にアクセスできるが、非推奨っぽい。そもそも集計時に `_source` を使うべきではないという意見もあったりして、将来どうなるかわからない。

動く Painless 版のサンプルとしては以下のような JSON になる。

```json
{
  "script_fields": {
    "correctYear": {
      "script": {
        "inline": "params._source.year - params.paramYear",
        "params": {
          "paramYear": 1800
        }
      }
    }
  },
  "query": {
    "term": {
      "title": "crime"
    }
  }
}
```

## Search Type, Preference の差異

https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-search-type.html のドキュメントによると、search type が `query_then_fetch` と `dfs_query_then_fetch` だけになっている。

また、custom value 以外の preference の種類も増えている。`_replica` や `_replica_first` など。 https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-preference.html

## `terms` クエリの `minimum_match`

2.4.2 で紹介されている `terms` クエリの `minimum_match` は使えなくなっている。代わりに `bool` クエリを使う。こんな感じかな。

```json
{
  "query": {
    "bool": {
      "should": [
        {
          "term": {
            "tags": "novel"
          }
        },
        {
          "term": {
            "tags": "book"
          }
        }
      ],
      "minimum_should_match": 1
    }
  }
}
```

## 削除されたクエリ

2.4.6 で紹介されている `field` クエリは削除されている。代わりに基本の `query_string` クエリを使う。

また、`fuzzy_like_this` および `fuzzy_like_this_field` クエリも削除されている

- https://www.elastic.co/guide/en/elasticsearch/reference/5.2//query-dsl-flt-query.html。
- https://www.elastic.co/guide/en/elasticsearch/reference/5.2//query-dsl-flt-field-query.html

`more_like_this` クエリは使えるが、`more_like_this_field` クエリは削除されている。

## `fuzzy` クエリ

2.4.11 で、どのくらいファジーに検索するかを指定するのに `min_similarity` を使っているが、`fuzziness` で指定する。本に出てきている例のように `cirme` でひっかけたければ、以下のように明示的に `fuzziness` を `2` に指定する必要がある。

```json
{
  "query": {
    "fuzzy": {
      "title": {
        "value": "cirme",
        "fuzziness": 2
      }
    }
  }
}
```

## フィルタの利用

2.5.1 でフィルタの利用法が解説されているが、`filtered` クエリは削除されて `bool` クエリに置き換えられるので、以下のように `must` と `filter` を使うようにしなければならない。

```json
{
  "query": {
    "bool": {
      "must": {
        "query_string": {
          "fields": [
            "title"
          ],
          "query": "Catch-22"
        }
      },
      "filter": {
        "term": {
          "year": 1961
        }
      }
    }
  }
}
```

ref. https://www.elastic.co/guide/en/elasticsearch/reference/5.1/query-dsl-filtered-query.html

また、2.5.2 の例も以下のように `bool` を使う必要がある。他の例も同じように書き換えれば動く。

```json
{
  "query": {
    "bool": {
      "filter": {
        "range": {
          "year": {
            "gte": 1930,
            "lte": 1990
          }
        }
      }
    }
  }
}
```

また、[`missing` クエリは削除された](https://www.elastic.co/guide/en/elasticsearch/reference/5.2/query-dsl-exists-query.html#_literal_missing_literal_query) ので、`must_not` で `exists` を否定するようにして書く必要がある。

```json
{
  "query": {
    "bool": {
      "must_not": {
        "exists": {
          "field": "year"
        }
      }
    }
  }
}
```

2.5.5 の script フィルタはこんな感じになる。

```json
{
  "query": {
    "bool": {
      "filter": {
        "script": {
          "script": {
            "inline": "params.now - doc['year'].value > 100",
            "params": {
              "now": 2013
            }
          }
        }
      }
    }
  }
}
```

`limit` フィルタも削除されているので、以下のように `terminate_after` パラメータを使う。

```json
{
  "query": {
    "match_all": {}
  },
  "terminate_after": 1
}
```

## 3.1.6 の structured_data.json

トップレベルが `book` では意図しないドキュメントが生えるので、以下のような JSON を食わせないといけない。

```json
{
  "author" : {
   "name" : {
    "firstName" : "Fyodor",
    "lastName" : "Dostoevsky"
   }
  },
  "isbn" : "123456789",
  "englishTitle" : "Crime and Punishment",
  "originalTitle" : "Преступлéние и наказáние",
  "year" : 1886,
  "characters" : [
   {
    "name" : "Raskolnikov"
   },
   {
    "name" : "Sofia"
   }
  ],
  "copies" : 0
}
```

## `required_field_match` のデフォルト値

[`required_field_match` のデフォルト値は `true` になっている](https://www.elastic.co/guide/en/elasticsearch/reference/5.2/search-request-highlighting.html#field-match) (書籍中では `false` であると説明されている) ので、ナイーブにハイライトをセットすると、検索に引っかかったプロパティのみがハイライトされる。

## mapper-attatchments プラグインは非推奨

mapper-attatchments プラグインは非推奨 となっているようなので、[ingest-attachment plugin](https://www.elastic.co/guide/en/elasticsearch/plugins/5.x/ingest-attachment.html) を使うと良い。

## トークナイザ・フィルタ

- `engram` は `edge_ngram` に改名されている。

## boost に関連する query DSL の違い

- Function Score Query の各 function の中でのブースト値は `boost_factor` ではなく `weight` を使う

## nodes info API, nodes stats API の仕様変更

以下のようにしてノードの情報を取得できるようになっている。

```
$ curl 'http://localhost:9200/_nodes/foobar/os,jvm'
$ curl 'http://localhost:9200/_nodes/foobar/stats/os,jvm'
```

## そのた

- インデックス作成のための API が POST メソッドではなく PUT メソッドに変わっている
- デフォルトの設定ではストップワードの省略を行わない
- river plugin は廃止
  - https://www.elastic.co/blog/deprecating-rivers 
- More Like This API は廃止

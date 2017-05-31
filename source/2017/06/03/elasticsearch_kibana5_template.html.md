---
title: Elasticsearch 5.x & Kibana 5 に移行したときになぜか棒が分割できない問題に対処したメモ
date: 2017-06-03
tags: elasticsearch, infra
---

古いバージョンの EC2 上で動く Elasticsearch と Kibana を AWS Elasticsearch Service (5.1) & Kibana 5 に移行するときに、ちょっとハマったポイントがあったのでメモとして残しておきます。

## 一部のレコードがなぜか aggregate できない

MySQL が吐くスロークエリログをいい感じにしたいとき、[fluent-plugin-mysqlslowquery](https://github.com/yuku-t/fluent-plugin-mysqlslowquery) を利用して Elasticsearch に送り、Kibana を使って視覚化する、という常套手段があります。
このとき、以下のスクリーンショットのような感じで Split Bars の Sub Aggregation に Temrs を指定し、スロークエリの SQL 文 (sql.keyword) で棒を分割するでしょう。

<a href="/2017/06/03/elasticsearch_kibana5_template/kibana_001.png" target="_blank">
  <img src="/2017/06/03/elasticsearch_kibana5_template/kibana_001.png" alt="スロークエリログを解析するときのKibana のグラフの設定例" style="width: 700px;">
</a>

このとき、雑に [fluent-plugin-mysqlslowquery](https://github.com/yuku-t/fluent-plugin-mysqlslowquery) を使って動的にマッピングしてレコードを投げ込むようにしていると、一部のレコードがなぜか aggregate できないという現象に悩まされることになります。

## Kibana 5 の設定画面でフィールドを見てみる

なにかがおかしいということで、Kibana 5 の設定画面でフィールドの様子を見てみます。
問題の sql.keyword ですが、きちんと aggregatable にチェックがついていますね。さてどうしたものか。

<a href="/2017/06/03/elasticsearch_kibana5_template/kibana_002.png" target="_blank">
  <img src="/2017/06/03/elasticsearch_kibana5_template/kibana_002.png" alt="slow_query-* のフィールドの様子" style="width: 700px;">
</a>


## マッピングを見てみる

Elasticsearch の [Mapping API](https://www.elastic.co/guide/en/elasticsearch/reference/5.1/mapping.html) を使って、マッピングを確認します。

```json
{
  "slow_query-2017.06.01": {
    "mappings": {
      "query_log": {
        "properties": {
          "@timestamp": {
            "type": "date"
          },
          // :
          // : 中略
          // :
          "sql": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          // :
          // : 中略
          // :
        }
      }
    }
  }
}
```

sql.keyword の `ignore_above: 256` がミソです。実は、Elasticsearch 5.x から雑に文字列を投げ込むとそれを string 型と解釈し、さらに text と keyword に分割するという挙動になっています。

参考: [Strings are dead, long live strings!](https://www.elastic.co/jp/blog/strings-are-dead-long-live-strings)

このとき aggregatable になるのは sql.keyword で、`ignore_above` に設定されている値以上の長さを持つ文字列はインデキシングされず、ストアもされません。つまり aggregate に使うことができません。
そして、この `ignore_above` のデフォルト値は `256` です。なので、256 文字を超えがちな SQL 文などで aggregate しようとするとつらい感じになります。

参考: [ignore_above | Elasticsearch Reference [5.1] | Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/5.1/ignore-above.html)

## どうにかするぞ

これをどうにかするには、以下のような方法が考えられます。

- サボらずにちゃんとマッピングを設定する
- index template と dynaminc mapping でデフォルト値を上書きする

理想はサボらずにちゃんとマッピングを設定することですが、節約のためにひとつの Elasticsearch クラスタにいろんなログを同居させている場合などは、ちまちまマッピングを設定するのも非現実的です。
ここでは、サボって dynaminc mapping によるデフォルト値の上書きで対処しました。

わたしは、こんな感じのテンプレートを設定しました。

```json

{
  "order": 0,
  "template": "*",
  "settings": {},
  "mappings": {
    "_default_": {
      "dynamic_templates": [
        {
          "rule1": {
            "mapping": {
              "type": "text",
              "fields": {
                "keyword": {
                  "ignore_above": 2048,
                  "type": "keyword"
                }
              }
            },
            "match_mapping_type": "string",
            "match": "*"
          }
        }
      ]
    }
  },
  "aliases": {}
}
```

こうすると、全てのインデックスにおいて、文字列の keyword フィールドの `ignore_above` のデフォルト値が 2048 になり、長い文字列でも aggregate することができるようになります :tada: :rabbit: :+1:

---
title: ElastiCache のパラメータグループの差分をシュッと見たい
date: 2019-05-09
tags: infra
---

RDS の場合だと GUI からパラメータグループの差分を見られて便利なのですが、ElastiCache にはそのような画面がない (ないよね?) ので、適当にスクリプトを書きました。

[https://github.com/mozamimy/toolbox/blob/master/ruby/elasticache_param_diff/elasticache_param_diff.rb](https://github.com/mozamimy/toolbox/blob/master/ruby/elasticache_param_diff/elasticache_param_diff.rb)

<p>
{{ embed_code "/2019/05/09/elasticache_param_diff.rb" }}
</p>

実行すると、こんな感じで差分が出てきます。実際には色もついてきれいです。

```
[20:14:42]mozamimy@P1323-18P13U:elasticache_param_diff (master) (-'x'-).oO(
(ins)> ec ruby elasticache_param_diff.rb default.redis2.8 default.janai.redis2.8
~ list-max-ziplist-value: "64" => "128"
~ timeout: "0" => "86400"
```

みなさん一家に一台、似たようなスクリプトを書いてそうなのですが、どうしてるんでしょうね。わたし気になります。(スクリプトの内容というよりも、これを人々にたずねたかった)

---
title: 「言語実装パターン」の LL(1) 再帰的下向き構文解析器を Rust で実装してみた
date: 2017-11-15
tags: rust, book
---

この記事は、[「言語実装パターン」の LL(1) 再帰的下向き字句解析器を Rust で実装してみた](/2017/11/12/lang_impl_patterns_2_2.html) の続きです。言語処理系の実装のセオリーと Rust を学ぶために、「言語実装パターン」で紹介されている各パターンを Rust で実装する活動の 2 回目です。

<a href="https://www.oreilly.co.jp/books/9784873115320/">
  O'Reilly Japan - 言語実装パターン

  <img alt='言語実装パターン表紙' src='/2017/11/12/lang_impl_patterns_2_2/lang_impl_patterns.jpg' style="width: 200px;">
</a>

## LL(1) 再帰的下向き構文解析器の実装

ここで作るのは、以下のような文法を持つ入力を受理するパーサです。

```
list     : '[' elements ']' ;
elements : element (',' element)*
element  : NAME | list;
NAME     : ('a'..'z'|'A'..'Z') + ;
```

つまり、以下のような入力が合法となります。

- `[usagi]`
- `[usagi, NEKO]`
- `[usagi, [NEKO, Dog]]`
- `[usagi, [NEKO, Dog], inko]`

実装は以下の GitHub リポジトリに置いてあります。この記事を書いている時点でのコミットになります。

[mozamimy/lang_impl_patterns at ba3a9abfbad18bfb00690a1b1534144932087e74](https://github.com/mozamimy/lang_impl_patterns/tree/ba3a9abfbad18bfb00690a1b1534144932087e74)

[「言語実装パターン」の LL(1) 再帰的下向き字句解析器を Rust で実装してみた](/2017/11/12/lang_impl_patterns_2_2.html) で作成した ll1\_lexer crate に含まれる lexer のコードをライブラリとして利用しているので、そちらもあわせてご覧ください。

### main.rs

<script src="https://gist-it.appspot.com/github/mozamimy/lang_impl_patterns/raw/ba3a9abfbad18bfb00690a1b1534144932087e74/ll1_parser/src/main.rs"></script>

前回の記事の時点で実装済みの `list_lexer` モジュールに含まれる `ListLexer` を生成し、それを入力として今回実装した `ListParser` に渡し、`list()` メソッドを呼ぶことでパースを開始します。無事パースができれば `Syntax is OK.` と標準出力に出力し、そうでなければ (やや雑ですが..) `panic!` します。

### list_parser.rs

<script src="https://gist-it.appspot.com/github/mozamimy/lang_impl_patterns/raw/ba3a9abfbad18bfb00690a1b1534144932087e74/ll1_parser/src/list_parser.rs"></script>

`ListParser` は入力 (`input`) である `ListLexer` と、LL(1) が LL(1) たるゆえんである先読みトークン `lookahead` を持ちます。`lookahead` は存在しないこともありうるため、`Option<T>` で包みます。

`[` や `,` などの終端記号を期待するときは `match_token()` で `lookahead` が期待されるトークンであるかをチェックし、期待されるトークンであれば `consume()` で食ってしまい、そうでなければ `panic!` します (つまり構文エラーである)。

`elements` などの非終端記号を期待する場合は、それに対応する関数を呼びます。

## まとめ

前回同様、書籍に掲載されているパターンを素朴に実装して構文解析器を実装して動かすことができました。とはいえ、まったく effective に書けている気はしません.. clone でコピーしまくっているし..。

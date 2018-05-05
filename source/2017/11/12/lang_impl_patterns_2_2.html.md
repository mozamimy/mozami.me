---
title: 「言語実装パターン」の LL(1) 再帰的下向き字句解析器を Rust で実装してみた
date: 2017-11-12
tags: rust, book
---

**(2017-11-13 ちょっとコードに変更を加えたので加筆修正しました)**

ごきげんよう。深夜のおかしな時間に起きてしまってついついケータイの公式アプリで Twitter を見てしまうとき、流速が遅いのについついリロードしてしまって、こんな感じになっちゃいますよね。もざみみです。

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">ｽｯ... ﾊﾟｯ (Twitterをリロードする音) ｽｯ... ﾊﾟｯ ｽｯ... ﾊﾟｯ ｽｯ... ﾊﾟｯ ｽｯ... ﾊﾟｯ ｽｯ... ﾊﾟｯ ｽｯ... ﾊﾟｯ ｽｯ... ﾊﾟｯ ｽｯ... ﾊﾟｯ ｽｯ... ﾊﾟｯ ｽｯ... ﾊﾟｯ ｽｯ... ﾊﾟｯ ｽｯ... ﾊﾟｯ ｽｯ... ﾊﾟｯ (Twitterをリロードする音)</p>&mdash; ᕱ⑅ᕱ もざみもざ (@mozamimy) <a href="https://twitter.com/mozamimy/status/929406274709569536?ref_src=twsrc%5Etfw">November 11, 2017</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

閑話休題。

少し前から自作言語を作ろうと思って意気込んでたのですが、あまりにも基礎教養がなさすぎて、セオリーがあるのはなんとなくわかっているけれど、コードに落とすところまで作業をすすめることが辛くなってきました。

こういうとき、初心者にとっては書籍の体系的な知識が役に立ちます。どんな本で学ぼうか考えていたときに、なんとなく目に止まったのがオライリーから販売されている「言語実装パターン」です。即ポチってしまいました。

<a href="https://www.oreilly.co.jp/books/9784873115320/">
  O'Reilly Japan - 言語実装パターン

  <img alt='言語実装パターン表紙' src='/2017/11/12/lang_impl_patterns_2_2/lang_impl_patterns.jpg' style="width: 200px;">
</a>

半分ほど読み進めたところで、紹介されているパターンを実際に手を動かして実装してみたくなってきました。書籍中で使われている Java や、慣れた言語でやってもあまり面白みがないので Rust でやっていきます :muscle:

今回は初回ということで、最初に実装例が出てくる LL(1) 再帰的下向き字句解析器を Rust で実装しました。

## LL(1) 再帰的下向き字句解析器の実装

実装は以下の GitHub リポジトリに置いてあります。この記事を書いている時点でのコミットになります。

[lang\_impl\_patterns/ll1\_lexer at ba3a9abfbad18bfb00690a1b1534144932087e74 · mozamimy/lang\_impl\_patterns](https://github.com/mozamimy/lang_impl_patterns/tree/ba3a9abfbad18bfb00690a1b1534144932087e74/ll1_lexer)

### main.rs

<script src="https://gist-it.appspot.com/github/mozamimy/lang_impl_patterns/raw/ba3a9abfbad18bfb00690a1b1534144932087e74/ll1_lexer/src/main.rs"></script>

エントリーポイントです。`drive()` 関数で lexer を生成して EOF が返ってくるまで token を拾ってきて、`output` 変数に雑に出力を付け足していき、最終的に `main()` 関数で結果を出力します。

### token.rs

<script src="https://gist-it.appspot.com/github/mozamimy/lang_impl_patterns/raw/ba3a9abfbad18bfb00690a1b1534144932087e74/ll1_lexer/src/token.rs"></script>

ファイル名の示すとおり、トークンを実装します。

書籍ではトークンの種類を単純な整数値で扱っていましたが、ここでは enum を使って素朴に実装しています。

### list\_lexer.rs

<script src="https://gist-it.appspot.com/github/mozamimy/lang_impl_patterns/raw/ba3a9abfbad18bfb00690a1b1534144932087e74/ll1_lexer/src/list_lexer.rs"></script>

実装の一番のキモです。書籍では Lexer クラスを継承して ListLexer クラスを実装していましたが、ここでは素朴に ListLexer 構造体に関数を実装する形にしました。

入力を `input` 変数に、先読みして見ている文字を `lookahead_chr` 変数に、現在の位置を `position` 変数に格納しておき、`next_token()` 関数で一つずつ前に先読みしながらトークンを出力していきます。`lookahead_chr` は空 (先読み文字が EOF の場合) があるので、`Option<char>` ように `Option<T>` を使うことで空という概念を扱えるようにしています。

各関数がやっていることはほぼ書籍のとおりです。Rust だと高級なパターンマッチを使うことができるので、そうでない言語よりも分岐をスマートに書けてよいですね。

## まとめ

Rust の筋トレと言語処理系の基礎教養を身につけるために、他のパターンも手を動かして実装していきます。

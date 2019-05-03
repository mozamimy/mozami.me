---
title: API と著作権
date: 2015-07-01
tags: thinking
---


![Java の本](/images/2015/07/01/api-right/api-right.jpg)  
photo credit: <a href="http://www.flickr.com/photos/44095870@N00/360029037">my textbook</a> via <a href="http://photopin.com">photopin</a> <a href="https://creativecommons.org/licenses/by/2.0/">(license)</a>

Oracle と Google が Java の API の著作権を巡って係争中でしたが、とうとう最高裁の判決が下りたようです（[Supreme Court denies Google request in Java infringement case | Computerworld](http://www.computerworld.com/article/2941596/android/supreme-court-denies-google-request-in-java-infringement-case.html)）。

このネタ、2 年ほど前からウォッチしていました。ちなみにわたしは、API に対する著作権は認めない派でした。なぜならば、著作権保護の対象になれば、あるプログラミング言語 X と、X に付属する標準ライブラリのオープンな実装ができなくなってしまうからです。

Google はここで降りずに、「確かに著作権保護の対象かもしれないが、フェアユースである」という論法に切り替えて、別の案件として審議を開始するようです。もしフェアユースであるであることが認められるならば、それが現実的な落としどころとして妥当そうです。

わたしは、「ハッカー文化の発展が妨げられるから」という理由で、著作権を認めないのが妥当だと考えていました。実際のところ、API の設計は深遠な問題で、そこにかかる労力とスキルを考えれば、著作権を認めるべきなのかもしれません。その上で、「フェアユースである」という結論に至れば、最も妥当なのかなと思うわけです。

とにもかくにも、これで「API に著作権を認める」という判例ができてしまったので、OSS プロジェクトにも少なからず影響はあるでしょう。OpenJDK は Oracle 傘下なので大丈夫でしょうが、仮に OpenJDK からフォークした Java の処理系とライブラリ群を作って訴えられたら、負ける可能性はグッと高まるでしょう。

今後の係争の行方が気になるところです。

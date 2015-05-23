2章 プログラムの意味
===========================

2.1 「意味」の意味
---------------------------

あるプログラミング言語の仕様を正確に記述する方法について。  
実装による仕様(Ruby, PHPなど)、公式文書の仕様書(C++, Java, ECMAScriptなど)、数学的に記述する方法などがある。


2.2 構文
--------------------------
- 構文…プログラムがどのように見えるか  
  構文が決まっていれば、parserで解析し、抽象構文木(Abstract Syntax Tree)に変換することができる

2.3 操作的意味論
--------------------------
- 意味論…プログラムが何を意味するか  
  操作的意味論。構成要素がどのように振る舞うか、何をするかを考えて、それらを組み合わせて大きなプログラムを作ると考える。


### スモールステップ意味論

SIMPLEという架空言語を考える。
SIMPLEの構成要素、Number、Add、MultiplyをRubyのクラスとして表現してみる。

[SIMPLE.rb](SIMPLE.rb)

これらのクラスを使い、手動で抽象構文木を作ることができる。

```ruby
Add.new(
  Multiply.new(Number.new(1), Number.new(2)),
  Multiply.new(Number.new(3), Number.new(4))
)
```

実行してみるとこの通り。

```bash
irb(main):001:0> require "./SIMPLE.rb"
=> true
irb(main):002:0> Add.new(Multiply.new(Number.new(1), Number.new(2)), Multiply.new(Number.new(3), Number.new(4)))
=> ≪1 * 2 + 3 * 4≫
```

`1*2+3*4`相当の構文を表すことができた。

#### 簡約(reduce)

SIMPLEはスモールステップで構文を繰り返し簡約(reduce)することで評価してゆく。

1. `1*2 + 3*4`
2. `2   + 3*4`
3. `2   + 12`
3. `14`

Number, Add, Multiplyにそれぞれ簡約可能であるかを示すメソッド`#reducible?`を追加する。
[reducible追加](https://github.com/hirak/memo-understanding-computation/commit/e6942b8d27c3787a4d0eaf0ed6e0c9e519f587e3)

実際にreduceメソッドを作ってみる。

AddとMultiplyは、左辺と右辺をそれぞれ簡約していき、reducible?がfalseだったら実際の簡約を実行する。

```ruby
$ irb
irb(main):001:0> require './SIMPLE.rb'
=> true
irb(main):002:0> ex = Add.new(Multiply.new(Number.new(1), Number.new(2)), Multiply.new(Number.new(3), Number.new(4)))
=> ≪1 * 2 + 3 * 4≫
irb(main):003:0> ex.reducible?
=> true
irb(main):004:0> ex = ex.reduce
=> ≪2 + 3 * 4≫
irb(main):005:0> ex.reducible?
=> true
irb(main):006:0> ex = ex.reduce
=> ≪2 + 12≫
irb(main):007:0> ex.reducible?
=> true
irb(main):008:0> ex = ex.reduce
=> ≪14≫
irb(main):009:0> ex.reducible?
=> false
```

reducible?とreduceを繰り返す部分を仮想機械としてまとめてみる。

Machineというクラスを作る。
[Machineクラス作成](https://github.com/hirak/memo-understanding-computation/commit/21de4b01fe347deae735fb75ec92e0215e850d0b)

Machine.newに対して抽象構文木を渡し、.runすると自動でreduceを繰り返すようになる。

ついでに要素を拡張してBooleanとLessThanを追加する。

```ruby
irb(main):001:0> require './SIMPLE.rb'
=> true
irb(main):002:0> Machine.new(
irb(main):003:1*   LessThan.new(Number.new(5), Add.new(Number.new(2), Number.new(2)))
irb(main):004:1> ).run
5 < 2 + 2
5 < 4
false
=> nil
```

#### 環境(environment)

次は変数だ。変数は名前と具体的な値を紐づける機能で、実現するためには覚えておくための機構が必要になる。
ここではRubyのハッシュを環境として使う。(つまり、レキシカルスコープはない）

environmentは全要素のreduceの引数に加えておく。
Machine.newの第二引数にハッシュを渡すことで、環境を考慮して動かせるようになった。

以下は`x=3; y=4; x+y`みたいなコードに相当する。

```ruby
irb(main):001:0> require './SIMPLE.rb'
=> true
irb(main):002:0> Machine.new(
irb(main):003:1*   Add.new(Variable.new(:x), Variable.new(:y)),
irb(main):004:1*   {x: Number.new(3), y: Number.new(4)}
irb(main):005:1> ).run
x + y
3 + y
3 + 4
7
=> nil
```

#### 文 (statement)

抽象機械の状態を変更することを目的とする、文(statement)というものを作ってみる。
文は式とは違い、別の式を生成したりしない。一番単純なのはDoNothing - 何もしない文である。

さっき変数(variable)を追加したけれど、あらかじめ環境に定義されているものを読み出すことしかできなかった。代入はまだどこにも定義されていない。これを追加してみる。

代入(Assign)は、`x = x + 1`の「=」のようなイメージだろうか。右辺を簡約し、その後左辺に示される変数の内容を更新する。また、代入文は代入された値自体を返すようにするのが一般的だ。
なので変更された後の環境と、戻り値の二つを返す必要がある。今回はRubyなので配列で２つを返すようにしてみた。

```ruby
$ irb
irb(main):001:0> require "./SIMPLE.rb"
=> true
irb(main):002:0> statement = Assign.new(:x, Add.new(Variable.new(:x), Number.new(1)))
=> 《x = x + 1》
irb(main):003:0> environment = { x: Number.new(2) }
=> {:x=>≪2≫}
irb(main):004:0> statement.reducible?
=> true
irb(main):005:0> statement, environment = statement.reduce(environment)
=> [《x = 2 + 1》, {:x=>≪2≫}]
irb(main):006:0> statement, environment = statement.reduce(environment)
=> [《x = 3》, {:x=>≪2≫}]
irb(main):007:0> statement, environment = statement.reduce(environment)
=> [《do-nothing》, {:x=>≪3≫}]
irb(main):008:0> statement.reducible?
=> false
```

代入文を簡約してゆくと、最終的にstatementはdo-nothingになって、簡約できなくなり、代入文の評価が終わる。

先ほど定義していた仮想機械はまだ式しか扱えなかった。文を定義し、同じように使えるようにしてみる。

https://github.com/hirak/memo-understanding-computation/commit/7e5334a999bd77ccd01749d6248bfb254f15e850


この調子で他の文も作ってみる。

if文は条件(condition)式、帰結(consequence)文、代替(alternative)文の3つが必要になる。

```ruby
irb(main):002:0> Machine.new(
irb(main):003:1*   If.new(
irb(main):004:2*     Variable.new(:x),
irb(main):005:2*     Assign.new(:y, Number.new(1)),
irb(main):006:2*     Assign.new(:y, Number.new(2))
irb(main):007:2>   ),
irb(main):008:1*   { x: Boolean.new(true) }).run
if (x) { y = 1 } else { y = 2 }, {:x=>《true》}
if (true) { y = 1 } else { y = 2 }, {:x=>《true》}
y = 1, {:x=>《true》}
do-nothing, {:x=>《true》, :y=>≪1≫}
=> nil
```

ちなみに、else句(alternative)のないif分が必要ならば、elseにdo-nothingを指定することで対処が可能になっている。


さらに、文なのだから、複数の式や文をつなげて実行できるようにすると便利だ。複文を表す「;」シーケンス(sequence)の誕生である。
`x = 1 + 1; y = x + 3`
この規則は少し複雑になる。

- 最初の文がdo-nothingの場合、次の文ともとのままのに簡約する。
- 最初の文がdo-nothingでない場合、最初の文をまず簡約し、新しいシーケンス文にして、さらに簡約された環境が得られる。

二つの式しかまとめられないが、入れ子になればよいので能力的には無限個の文をまとめることができる。
https://github.com/hirak/memo-understanding-computation/commit/b6c96c71be99038ecba3ae25954654194334813e

```ruby
irb(main):002:0> Machine.new(
irb(main):003:1*   Sequence.new(
irb(main):004:2*     Assign.new(:x, Add.new(Number.new(1), Number.new(2))),
irb(main):005:2*     Assign.new(:y, Add.new(Variable.new(:x), Number.new(3)))
irb(main):006:2>   ),
irb(main):007:1*   {}
irb(main):008:1> ).run
x = 1 + 2; y = x + 3, {}
x = 3; y = x + 3, {}
do-nothing; y = x + 3, {:x=>≪3≫}
y = x + 3, {:x=>≪3≫}
y = 3 + 3, {:x=>≪3≫}
y = 6, {:x=>≪3≫}
do-nothing, {:x=>≪3≫, :y=>≪6≫}
=> nil
```

最後に、ループ構文whileを考える。whileは条件(condition)式と、本体(body)と呼ばれる文がある。
スモールステップ意味論においては直接実行するのではなく、シーケンスを使ってwhileを一段展開する。

1. while (condition) { body }
2. if condition { body; while (condition) { body } } else { do-nothing }

これを繰り返すと、while文がひたすら展開されて、最終的には平べったくなる。


```ruby
irb(main):002:0> Machine.new(
irb(main):003:1*   While.new(
irb(main):004:2*     LessThan.new(Variable.new(:x), Number.new(5)),
irb(main):005:2*     Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
irb(main):006:2> ),
irb(main):007:1* {x: Number.new(1)}
irb(main):008:1> ).run
while (x < 5) { x = x * 3 }, {:x=>≪1≫}
if (x < 5) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=>≪1≫}
if (1 < 5) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=>≪1≫}
if (true) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=>≪1≫}
x = x * 3; while (x < 5) { x = x * 3 }, {:x=>≪1≫}
x = 1 + 3; while (x < 5) { x = x * 3 }, {:x=>≪1≫}
x = 4; while (x < 5) { x = x * 3 }, {:x=>≪1≫}
do-nothing; while (x < 5) { x = x * 3 }, {:x=>≪4≫}
while (x < 5) { x = x * 3 }, {:x=>≪4≫}
if (x < 5) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=>≪4≫}
if (4 < 5) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=>≪4≫}
if (true) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=>≪4≫}
x = x * 3; while (x < 5) { x = x * 3 }, {:x=>≪4≫}
x = 4 + 3; while (x < 5) { x = x * 3 }, {:x=>≪4≫}
x = 7; while (x < 5) { x = x * 3 }, {:x=>≪4≫}
do-nothing; while (x < 5) { x = x * 3 }, {:x=>≪7≫}
while (x < 5) { x = x * 3 }, {:x=>≪7≫}
if (x < 5) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=>≪7≫}
if (7 < 5) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=>≪7≫}
if (false) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=>≪7≫}
do-nothing, {:x=>≪7≫}
=> nil
```

while文はif文だったのか。。
ここまでで、一応のプログラミング言語が完成したことになる。（あまり役には立たないが。）


### ビッグステップ意味論

スモールステップ意味論では、解析のしやすい小さなパーツを少しずつ簡約することで意味を記述した。反面、間接的に見えるかも。
一気に文がどのように動くのか記述できないだろうか。それがビッグステップ意味論である。

プログラムとして直接実行できる定義。(Lispっぽいかも)

基本的にプログラムの実行プロセスを反復ではなく再帰(recursive)としてみなしてゆく。
ただし、スモールステップ意味論ではできていた、処理の順番と言った細かな定義ができないことに注意が必要である。

ビッグステップ意味論では、記述そのものが動作できるため、仮想機械という概念が不要になる。
代わりにそれぞれの式はevaluateというメソッドを持つ。

即座に自分自身に評価される式か、計算を実行して別の式に評価される式か、どちらかになる。

#### ビッグステップ意味論における文

ビッグステップでは文の扱いが簡単になる。変更途中の環境が登場せず、文（環境を変えるもの）のevaluateは変更後の環境をいきなり返すようにすればよい。

```ruby
irb(main):002:0> statement =
irb(main):003:0*   While.new(
irb(main):004:1*   LessThan.new(Variable.new(:x), Number.new(5)),
irb(main):005:1*   Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
irb(main):006:1> )
=> 《while (x < 5) { x = x * 3 }》
irb(main):007:0> statement.evaluate({x: Number.new(1)})
=> {:x=>≪9≫}
```

### これらは何だったのか

スモールステップ意味論とビッグステップ意味論は、実はインタプリタ(interpreter)の実装になっている。
つまり、インタプリタを実装することで、未知のプログラミング言語の仕様を記述できたわけだ。



2.4 表示的意味論
---------------------

表示的意味論(denotational semantics)では、プログラムをネイティブ言語から別の表現に変換することで意味を記述する。

より低レベルで安定していて理解されている言語に翻訳することで、未知の言語を理解できるようにする。

今回はSIMPLEをrubyに変換することで、表示的意味論のアプローチを執り行う。

各要素に`to_ruby`メソッドを追加する。

SIMPLE -> `to_ruby` -> Rubyとして妥当なプログラムコード -> evalすると、実行できる

```ruby
irb(main):002:0> Number.new(5).to_ruby
=> "-> e { 5 }"
irb(main):003:0> Boolean.new(false).to_ruby
=> "-> e { false }"
```


```ruby
irb(main):002:0> Add.new(Variable.new(:x), Number.new(1)).to_ruby
=> "-> e { (-> e { e[:x] }).call(e) + (-> e { 1 }).call(e) }"
irb(main):003:0> LessThan.new(Add.new(Variable.new(:x), Number.new(1)), Number.new(3)).to_ruby
=> "-> e { (-> e { (-> e { e[:x] }).call(e) + (-> e { 1 }).call(e) }).call(e) < (-> e { 3 }).call(e) }"
irb(main):004:0> proc = LessThan.new(Add.new(Variable.new(:x), Number.new(1)), Number.new(3)).to_ruby
=> "-> e { (-> e { (-> e { e[:x] }).call(e) + (-> e { 1 }).call(e) }).call(e) < (-> e { 3 }).call(e) }"
irb(main):005:0> environment = {x: 3}
=> {:x=>3}
irb(main):006:0> proc = eval(proc)
=> #<Proc:0x007f7fe9505800$this->(eval):1 (lambda)>
irb(main):007:0> proc.call(environment)
=> false
```

rubyのコードなんだけど、翻訳されて出てくる文字列は凄まじいですね。。

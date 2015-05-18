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

さっき変数(variable)を追加したけれど、あらかじめ環境に定義されているものを読み出すことしかできなかった。代入文はまだどこにも定義されていない。これを追加してみる。

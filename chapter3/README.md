3章 最も単純なコンピュータ
=================================

oO(正規表現みたいな話かな？)

3.1 決定性有限オートマトン
---------------------------------

非常に単純なコンピュータとして、有限状態機械(finite state machine)もしくは有限オートマトン(finite automaton)と呼ばれるものを考える。

1. FSMには入力として文字のストリームが渡される。
2. FSMは入力を受けて状態を遷移させてゆく。(状態遷移図っぽい設計図で書ける)
3. 入力ストリームが終わったとき行き着いた状態が「受理」だったらtrue、「拒否」だったらfalseを返却する。

文字のマッチングとかに使うイメージだ。

まずは、入力ストリームに対して決定的である機械を考える。これを決定性有限オートマトンと呼ぶ。DFA: Deterministic Finite Automaton

常に次に進むべき情報は一つに定まるようになっているのが特徴。(どっちの状態にも遷移できるから迷う、みたいなことが起きえないように作ってある）

DFAをrubyで再現するために、いくつかのクラスを定義する。

- FARule ...一つ一つの規則を表す。
  - applies_to? 規則を適用できるか返す
  - follow 規則を適用するときに機械をどのように変更するか返す
- DFARulebook ...FARuleを束ねた規則集。
  - next_state ...現在の状態を引数に取って次の状態を返す。
  - rule_for ...次の文字から、適用できる規則を探して返す。(内部用)
- DFA ...DFARulebookから受理状態かどうかを返す。受理状態はコンストラクタで複数渡すことができる。
  - accepting? ...受理状態かどうか。
  - read_character ...入力から一文字読んで、規則集を調べて、現在の状態を変更する。
  - read_string ...文字列を一気に読み込んで、状態を変更する便利メソッド

```ruby
irb(main):001:0> require './automaton.rb'
=> true
irb(main):002:0> rulebook = DFARulebook.new([
irb(main):003:2* FARule.new(1, 'a', 2), FARule.new(1, 'b', 1),
irb(main):004:2* FARule.new(2, 'a', 2), FARule.new(2, 'b', 3),
irb(main):005:2* FARule.new(3, 'a', 3), FARule.new(3, 'b', 3)
irb(main):006:2> ])
=> #<struct DFARulebook rules=[#<FARule 1 --a--> 2>, #<FARule 1 --b--> 1>, #<FARule 2 --a--> 2>, #<FARule 2 --b--> 3>, #<FARule 3 --a--> 3>, #<FARule 3 --b--> 3>]>
irb(main):007:0> rulebook.next_state(1, 'a')
=> 2
irb(main):008:0> rulebook.next_state(1, 'b')
=> 1
irb(main):009:0> rulebook.next_state(2, 'b')
=> 3
```

実行途中の様子は[run.rb](run.rb)にまとめた。(長いので。。)

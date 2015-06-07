require './REGEXP.rb'

pattern = Repeat.new(
  Choose.new(
    Concatenate.new(Literal.new('a'), Literal.new('b')),
    Literal.new('a')
  )
)

puts pattern.inspect

puts '---------------------'

nfa_design = Empty.new.to_nfa_design

puts nfa_design.accepts?('')
puts nfa_design.accepts?('a')

nfa_design = Literal.new('a').to_nfa_design

puts nfa_design.accepts?('')
puts nfa_design.accepts?('a')
puts nfa_design.accepts?('b')

puts '--------matches---------'
puts Empty.new.matches?('a')
puts Literal.new('a').matches?('a')

puts '------- Concatenate ------------'
pattern = Concatenate.new(
  Literal.new('a'),
  Concatenate.new(Literal.new('b'), Literal.new('c'))
)

puts pattern.inspect

puts pattern.matches?('a')
puts pattern.matches?('ab')
puts pattern.matches?('abc')


puts '------- Choose ----------------'

pattern = Choose.new(Literal.new('a'), Literal.new('b'))
puts pattern.inspect

puts pattern.matches? 'a'
puts pattern.matches? 'b'
puts pattern.matches? 'c'


puts '------- Repeat --------'

pattern = Repeat.new(Literal.new('a'))
puts pattern.inspect

puts pattern.matches? ''
puts pattern.matches? 'a'
puts pattern.matches? 'aaaa'
puts pattern.matches? 'b'

puts '------- 複雑なパターン -------------'
pattern =
  Repeat.new(
    Concatenate.new(
      Literal.new('a'),
      Choose.new(Empty.new, Literal.new('b'))
    )
)

puts pattern.inspect


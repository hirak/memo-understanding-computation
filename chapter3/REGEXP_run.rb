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

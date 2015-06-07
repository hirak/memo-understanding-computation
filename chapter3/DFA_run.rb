require './DFA.rb'

rulebook = DFARulebook.new([
  FARule.new(1, 'a', 2), FARule.new(1, 'b', 1),
  FARule.new(2, 'a', 2), FARule.new(2, 'b', 3),
  FARule.new(3, 'a', 3), FARule.new(3, 'b', 3)
])

puts '--------- DFA.accepting? ---------'
puts DFA.new(1, [1, 3], rulebook).accepting?
puts DFA.new(1, [3], rulebook).accepting?

puts '--------- DFA.read_character -----'
dfa = DFA.new(1, [3], rulebook)
puts dfa.accepting?

dfa.read_character('b')
puts dfa.accepting?

3.times do
  dfa.read_character('a')
end
puts dfa.accepting?

dfa.read_character('b');
puts dfa.accepting?

puts '--------- DFA.read_string -----'
dfa = DFA.new(1, [3], rulebook)
puts dfa.accepting?

dfa.read_string('baaab')
puts dfa.accepting?

puts '--------- DFADesign -----------'

dfa_design = DFADesign.new(1, [3], rulebook)
puts dfa_design.accepts?('a')
puts dfa_design.accepts?('baa')
puts dfa_design.accepts?('baba')


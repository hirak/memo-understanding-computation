require './Simulation.rb'

rulebook = NFARulebook.new([
  FARule.new(1, 'a', 1), FARule.new(1, 'a', 2), FARule.new(1, nil, 2),
  FARule.new(2, 'b', 3),
  FARule.new(3, 'b', 1), FARule.new(3, nil, 2)
])

nfa_design = NFADesign.new(1, [3], rulebook)

puts nfa_design.to_nfa.current_states.inspect

puts nfa_design.to_nfa(Set[2]).current_states.inspect

puts nfa_design.to_nfa(Set[3]).current_states.inspect

nfa = nfa_design.to_nfa(Set[2, 3])
puts nfa.inspect

nfa.read_character('b')
puts nfa.current_states.inspect

puts '------------ Simulation --------------'
simulation = NFASimulation.new(nfa_design)
puts simulation.next_state(Set[1, 2], 'a').inspect
puts simulation.next_state(Set[1, 2], 'b').inspect
puts simulation.next_state(Set[3, 2], 'b').inspect
puts simulation.next_state(Set[1, 3, 2], 'b').inspect
puts simulation.next_state(Set[1, 3, 2], 'a').inspect


puts rulebook.alphabet.inspect
puts simulation.rules_for(Set[1, 2]).inspect
puts simulation.rules_for(Set[3, 2]).inspect

start_state = nfa_design.to_nfa.current_states

puts simulation.discover_states_and_rules(Set[start_state]).inspect


puts '------------trans--------------'

dfa_design = simulation.to_dfa_design
puts dfa_design.inspect

puts dfa_design.accepts?('aaa')
puts dfa_design.accepts?('aab')
puts dfa_design.accepts?('bbbabb')

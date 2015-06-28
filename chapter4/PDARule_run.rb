require './pda.rb'

rule = PDARule.new(1, '(', 2, '$', ['b', '$'])
puts rule.inspect

configuration = PDAConfiguration.new(1, Stack.new(['$']))
puts configuration.inspect

puts rule.applies_to?(configuration, '(')

puts '------------------------------'

puts rule.follow(configuration).inspect

puts '------------------------------'

rulebook = DPDARulebook.new([
  PDARule.new(1, '(', 2, '$', ['b', '$']),
  PDARule.new(2, '(', 2, 'b', ['b', 'b']),
  PDARule.new(2, ')', 2, 'b', []),
  PDARule.new(2, nil, 1, '$', ['$'])
])

puts configuration = rulebook.next_configuration(configuration, '(')
puts configuration = rulebook.next_configuration(configuration, '(')
puts configuration = rulebook.next_configuration(configuration, ')')

puts '---------------DPDA--------------'

dpda = DPDA.new(PDAConfiguration.new(1, Stack.new(['$'])), [1], rulebook)
puts dpda.accepting?

dpda.read_string('(()')
puts dpda.accepting?

puts dpda.current_configuration

puts '---------------freemove--------------'

configuration = PDAConfiguration.new(2, Stack.new(['$']))
puts configuration

rulebook.follow_free_moves(configuration)
puts rulebook

puts '---------------)))))-----------------'

dpda = DPDA.new(PDAConfiguration.new(1, Stack.new(['$'])), [1], rulebook)

dpda.read_string('(()(')
puts dpda.accepting?

puts dpda.current_configuration
dpda.read_string('))()')
puts dpda.accepting?

puts dpda.current_configuration

puts '---------------design ---------------'
dpda_design = DPDADesign.new(1, '$', [1], rulebook)
puts dpda_design.accepts?('(((((())))))')
puts dpda_design.accepts?('()()()()(((((()()))))')
puts dpda_design.accepts?('((()()()()((()()))))(')

#puts '-------------design?-----------------'
#dpda = DPDA.new(PDAConfiguration.new(1, Stack.new(['$'])), [1], rulebook)
#dpda.read_string('())')
#puts dpda.current_configuration

#puts dpda_design.accepts?('())')
#
puts '-----ab-----'
rulebook = DPDARulebook.new([
  PDARule.new(1, 'a', 2, '$', ['a', '$']),
  PDARule.new(1, 'b', 2, '$', ['b', '$']),
  PDARule.new(2, 'a', 2, 'a', ['a', 'a']),
  PDARule.new(2, 'b', 2, 'b', ['b', 'b']),
  PDARule.new(2, 'a', 2, 'b', []),
  PDARule.new(2, 'b', 2, 'a', []),
  PDARule.new(2, nil, 1, '$', ['$'])
])

dpda_design = DPDADesign.new(1, '$', [1], rulebook)
puts dpda_design.accepts?('ababab')
puts dpda_design.accepts?('bbbaaaab')
puts dpda_design.accepts?('baa')

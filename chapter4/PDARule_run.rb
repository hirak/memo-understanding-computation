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

require './pda.rb'

rule = PDARule.new(1, '(', 2, '$', ['b', '$'])
puts rule.inspect

configuration = PDAConfiguration.new(1, Stack.new(['$']))
puts configuration.inspect

puts rule.applies_to?(configuration, '(')

puts '------------------------------'

puts rule.follow(configuration).inspect

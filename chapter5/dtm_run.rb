require './dtm'

tape = Tape.new(['1', '0', '1'], '1', [], '_')
p tape

p tape.move_head_left
p tape.write('0')
p tape.move_head_right
p tape.move_head_right.write('0')

p '-------------TMRule--------------'

rule = TMRule.new(1, '0', 2, '1', :right)
p rule

p rule.applies_to?(TMConfiguration.new(1, Tape.new([], '0', [], '_')))
p rule.applies_to?(TMConfiguration.new(1, Tape.new([], '1', [], '_')))
p rule.applies_to?(TMConfiguration.new(2, Tape.new([], '0', [], '_')))

p rule.follow(TMConfiguration.new(1, Tape.new([], '0', [], '_')))

p '-------------DTMRulebook---------------'

rulebook = DTMRulebook.new([
  TMRule.new(1, '0', 2, '1', :right),
  TMRule.new(1, '1', 1, '0', :left),
  TMRule.new(1, '_', 2, '1', :right),
  TMRule.new(2, '0', 2, '0', :right),
  TMRule.new(2, '1', 2, '1', :right),
  TMRule.new(2, '_', 3, '_', :left),
])

p rulebook

configuration = TMConfiguration.new(1, tape)
p configuration = rulebook.next_configuration(configuration)
p configuration = rulebook.next_configuration(configuration)
p configuration = rulebook.next_configuration(configuration)

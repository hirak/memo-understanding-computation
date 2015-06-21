require './Stack.rb'

stack = Stack.new(%w{a b c d e})
puts stack.inspect
puts stack.top
puts stack.pop.pop.top
puts stack.push('x').push('y').top
puts stack.push('x').push('y').pop.top

require './dtm'

tape = Tape.new(['1', '0', '1'], '1', [], '_')
p tape

p tape.move_head_left
p tape.write('0')
p tape.move_head_right
p tape.move_head_right.write('0')



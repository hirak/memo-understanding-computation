require './number'
require './bool'
require './is_zero'
require './pair'
require './calc'
require './list'

MAP[RANGE[ONE][HUNDRED]][-> n {
  IF[IS_ZERO[MOD[n][FIFTEEN]]][
    'FizzBuzz'
  ][IF[IS_ZERO[MOD[n][THREE]]][
    'Fizz'
  ][IF[IS_ZERO[MOD[n][FIVE]]][
    'Buzz'
  ][
    n.to_s
  ]]]
}]


def to_boolean(proc)
  proc[true][false]
end

# TRUE/FALSEだと定義済みとしてエラーが出てしまう
T = -> x { -> y { x } }
F = -> x { -> y { y } }

IF =
  -> b {
    -> x {
      -> y {
        b[x][y]
      }
    }
  }


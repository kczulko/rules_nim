proc addTwoIntegers(a, b: cint): cint {.importc.}

when isMainModule:
  echo addTwoIntegers(3, 7)